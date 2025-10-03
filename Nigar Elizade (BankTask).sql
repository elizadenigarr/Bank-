--1. Son 3 ayda ümumilikdə ən çox əməliyyat edən müştəri (Musteri adi) və bu müştərinin əməliyyatlarının ümumi məbləğini göstərən sorğu yazın.   
select c.first_name,count(t.transaction_id) as emeliyyat_sayi,sum(t.amount) as umumi_mebleg
from transactions t
join accounts a on a.account_id=t.account_id
join customers c on c.customer_id=a.customer_id
where t.transaction_date>=add_months(sysdate,-3)
group by first_name
fetch first 1 rows only;

--2. Hər müştəri üçün son 1 ildə kart hesabından edilən çıxarışların sayını və bu çıxarışların ümumi məbləğini göstərin.
select c.first_name||' '||c.last_name as ad_ve_soyad ,count(t.transaction_id) as cixarilis_sayi,sum(t.amount) as umumi_mebleg
from transactions t
join accounts a on a.account_id=t.account_id
join customers c on c.customer_id=a.customer_id
where t.transaction_date>=add_months(sysdate,-12)
and a.account_type='Card Account'
and t.transaction_type='Withdrawal'
group by c.first_name||' '||c.last_name;

--3. Hər müştəri üçün son 6 ay ərzində edilən əməliyyatların sayına görə, ən çox əməliyyat edən hesab növünü müəyyən edin.
select musteri_adi, hesab_novu
from
    (select
        c.first_name || ' ' || c.last_name as musteri_adi,
        a.account_type as hesab_novu,
        count(t.transaction_id) as emeliyyat_sayi,
        rank() over (partition by c.first_name || ' ' || c.last_name order by count(t.transaction_id) desc) as rn
    from customers c
    join accounts a
        on a.customer_id=c.customer_id 
    join transactions t
        on t.account_id=a.account_id
    where
        t.transaction_date >= add_months((select max(transaction_date) from transactions), -6)
    group by c.first_name, c.last_name ,  a.account_type) t
where rn=1;

--4. Müştərilərin son 1 ildə yalnız depozit hesabları ilə bağlı etdikləri əməliyyatların ümumi məbləğini təhlil edin.
select c.first_name||' '||c.last_name as ad_ve_soyad ,count(t.transaction_id) as cixarilis_sayi,sum(t.amount) as umumi_mebleg
from transactions t
join accounts a on a.account_id=t.account_id
join customers c on c.customer_id=a.customer_id
where t.transaction_date>=add_months(sysdate,-12)
and a.account_type='Deposit Account'
group by c.first_name||' '||c.last_name;

--5. Hər müştəri üçün son 3 ayda, ən çox kart əməliyyatlarını həyata keçirən tarixləri göstərin.                    
select
    musteri_adi,transaction_date,emeliyyat_sayi
from
    (select 
        c.first_name || ' ' || c.last_name as musteri_adi ,
        trunc(t.transaction_date) as transaction_date,
        count(t.transaction_id) as emeliyyat_sayi,
        rank() over(partition by c.first_name || ' ' || c.last_name order by count(t.transaction_id) desc) as rn
    from transactions t
    join accounts a on a.account_id=t.account_id
    join customers c on c.customer_id=a.customer_id
    where
        t.transaction_date >= add_months((select max(transaction_date) from transactions), -3)
        and upper(a.account_type)='CARD ACCOUNT'
    group by 
        c.first_name, c.last_name, trunc(t.transaction_date)
    )
where rn=1;              
                
--6. Aktiv depoziti olan müştərilərin depozit və kredit məlumatlarının siyahısını çıxarmaq:
select c.first_name, d.deposit_id,d.deposit_amount,d.deposit_type,l.loan_id,l.loan_amount,l.loan_type from customers c
join accounts a
on a.customer_id = c.customer_id
join deposits d 
on c.customer_id=d.customer_id
join loans l 
on c.customer_id=l.customer_id
join transactions tr
on a.account_id = tr.account_id
where tr.transaction_type = 'Deposit' and c.status = 'ACTIVE';

select * from deposits;
select * from transactions;
select * from accounts;
select * from loans;
select * from customers;
--7. Hər müştəri üçün son 1 il ərzində hər ay üzrə ümumi balans və depozit məbləğini göstərmək üçün sorğu yazın:
select c.first_name,to_char(t.transaction_date,'YYYY-MM') as ay, sum(a.balance)as umumi_balans,sum(case when a.account_type='Deposit Account' then t.amount else 0 end) as depozit_meblegi from accounts a
join customers c on c.customer_id=a.customer_id
join transactions t on t.account_id=a.account_id
where t.transaction_date>=add_months(sysdate,-12)
group by c.first_name,to_char(t.transaction_date,'YYYY-MM')
order by ay;

--8. Son 6 ayda ən yüksək kredit məbləğinə sahib olan müştəri haqqında məlumatlar və kredit məbləğini göstərmək.
select c.first_name||' '||c.last_name as ad_ve_soyad,l.loan_type from loans l
join customers c on c.customer_id=l.customer_id
where l.start_date>=add_months(sysdate,-6)
fetch first 1 rows only;

--9. Hər müştərinin son 6 ay ərzində etdiyi ən yüksək məbləğli əməliyyatla bağlı məlumatları (əməliyyat növü, tarix, balans) göstərin.
select c.customer_id,c.first_name,t.transaction_type,t.amount,t.transaction_date, a.balance from customers c
join accounts a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id
where t.transaction_date >= add_months(sysdate,-6) 
and t.amount=(
              select max(t2.amount)
            from transactions t2
            join accounts a2 on t2.account_id=a2.account_id
            where a2.customer_id=c.customer_id
            and t2.transaction_date >= add_months(sysdate,-6));

--10. Müştəri ən çox hansı növ kreditlərə müraciət edir və bu kreditlərin növü ilə müştəriyə təklif olunan ortalama faiz dərəcəsi nə qədər təşkil edir?  
select l.loan_type,count(*) as kredit_sayi,avg(l.interest_rate) as ortalama_faiz from loans l
group by loan_type;

--11. Hər müştərinin son 1 ildə açdığı bütün hesabları və bu hesablara görə edilən əməliyyatların ümumi məbləğini göstərmək:
select c.first_name,a.account_id,a.account_type,sum(t.amount) as umumi_mebleg from accounts a
join customers c on c.customer_id=a.customer_id
join transactions t on t.account_id=a.account_id
where a.date_opened>=add_months(sysdate,-12)
group by c.first_name,a.account_id,a.account_type;

--12. Hər müştəri üçün son 1 ildə hər ay üzrə ümumi balans və depozit məbləğini göstərən sorğu:
select c.first_name,to_char(t.transaction_date,'YYYY-MM') as ay, sum(a.balance)as umumi_balans,sum(case when a.account_type='Deposit Account' then t.amount else 0 end) as depozit_meblegi from accounts a
join customers c on c.customer_id=a.customer_id
join transactions t on t.account_id=a.account_id
where t.transaction_date>=add_months(sysdate,-12)
group by c.first_name,to_char(t.transaction_date,'YYYY-MM')
order by ay;

--13. Hər bir müştəri üçün son 1 ildə ən yüksək depozit məbləği ilə saxlanılan hesab növünü və bu hesabın açılış tarixini tapın.
select
    d.customer_id,
    a.account_type,
    d.max_deposit,
    a.date_opened as hesab_acilis_tarixi
from 
    (select
        customer_id,
        max(deposit_amount) as max_deposit
    from 
        deposits
    where 
       start_date >= add_months((select max(start_date) from deposits), -12)
    group by 
        customer_id
    ) d
join 
    accounts a
    on d.customer_id = a.customer_id;
    
--14. Hər müştərinin son 3 ayda kartlar ilə edilən əməliyyatların sayına görə ən aktiv kart növünü müəyyən edin.
select c.first_name as ad,
       cr.card_type as kart_novu,
       count(*) as emeliyyat_sayi
from accounts a
join transactions t
    on a.account_id = t.account_id
join customers c
    on c.customer_id = a.customer_id
join cards cr
    on cr.customer_id = c.customer_id
where t.transaction_date >= add_months(sysdate, -12)
      and a.account_type = 'Card Account'
group by c.first_name, cr.card_type
order by emeliyyat_sayi desc;
                              
--15. Müştəri statusu aktiv olanların içərisində Müddət bölgüsü üzrə ümumi kredit məbləğlərini hesablayın.
(Müddət bölgüsü dedikdə kreditin verilmə müddəti nəzərdə tutulur (start_date və end_date). Müddət bölgü aşağıdakı kimi olmalıdır.
0-12 ay
13-24 ay
25-48 ay
48 ay+)

select 
   case when months_between(l.end_date,l.start_date)<=12 then '0-12 ay'
        when months_between(l.end_date,l.start_date) between 13 and 24 then '13-24 ay'
        when months_between(l.end_date,l.start_date) between 25 and 48 then '25-48 ay'
        else '48+ ay'
   end as muddet_bolgusu, sum(l.loan_amount) as umumi_mebleg from loans l
join customers c on c.customer_id=l.customer_id
where c.status='ACTIVE'
group by 
   case when months_between(l.end_date,l.start_date)<=12 then '0-12 ay'
        when months_between(l.end_date,l.start_date) between 13 and 24 then '13-24 ay'
        when months_between(l.end_date,l.start_date) between 25 and 48 then '25-48 ay'
        else '48+ ay'
   end;