a=NCopt;
b=find(NCs==a);
c=labels(:,b);
e=data(:,1);
f=data(:,2);
h1=gscatter(e,f,c);
legend(h1);
xlabel('Latitude');
ylabel('Longitude');
