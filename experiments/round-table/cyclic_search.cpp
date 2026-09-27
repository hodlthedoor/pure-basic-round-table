// Experimental search for cyclic starting rows. Not production application code.
// stdout: starting rows, 1-based. stderr: search diagnostics. Exit 2: time limit.
#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <map>
#include <numeric>
#include <random>
#include <vector>
using namespace std;
int main(int argc, char **argv) {
    if (argc < 2) return 1;
    int n=atoi(argv[1]);
    if(n<4 || n>21) return 1;
    int m=n-(n%2 ? 2:1), k=(n-1)*(n-2)/2/m;
    double seconds=argc>2 ? atof(argv[2]):30;
    mt19937 rng(argc>3 ? atoi(argv[3]):1);
    int ids[22][22][22] = {};
    map<int,int> classes;
    for(int c=0;c<n;c++) for(int a=0;a<n;a++) for(int b=a+1;b<n;b++) {
        if(c==a || c==b) continue;
        int canonical=n*n*n;
        for(int t=0;t<m;t++) {
            int cc=c<m?(c+t)%m:c, aa=a<m?(a+t)%m:a, bb=b<m?(b+t)%m:b;
            if(aa>bb) swap(aa,bb);
            canonical=min(canonical,(cc*n+aa)*n+bb);
        }
        if(!classes.count(canonical)) classes[canonical]=classes.size();
        ids[c][a][b]=ids[c][b][a]=classes[canonical];
    }
    if(int(classes.size())!=n*k) return 1;
    auto start=chrono::steady_clock::now();
    auto elapsed=[&](){return chrono::duration<double>(chrono::steady_clock::now()-start).count();};
    vector<vector<int>> rows(k,vector<int>(n));
    vector<int> counts(classes.size());
    int best=n*k, score=0;
    uniform_real_distribution<double> unit(0,1);
    long long iterations=0;
    while(elapsed()<seconds) {
        fill(counts.begin(),counts.end(),0); score=0;
        for(auto &row:rows) {
            iota(row.begin(),row.end(),0); swap(row[0],row[m]);
            shuffle(row.begin()+1,row.end(),rng);
            for(int p=0;p<n;p++) score+=counts[ids[row[p]][row[(p+n-1)%n]][row[(p+1)%n]]]++;
        }
        for(int step=0;step<3000000;step++,iterations++) {
            if((step&65535)==0 && elapsed()>=seconds) break;
            if(score==0) {
                cerr<<"SOLVED n="<<n<<" seconds="<<elapsed()<<" iterations="<<iterations<<"\n";
                for(auto &row:rows) { for(auto v:row) cout<<v+1<<' '; cout<<'\n'; }
                return 0;
            }
            int r=rng()%k,a=1+rng()%(n-1),b=1+rng()%(n-1);
            if(a==b) continue;
            auto &row=rows[r];
            int positions[6]={(a+n-1)%n,a,(a+1)%n,(b+n-1)%n,b,(b+1)%n};
            sort(positions,positions+6);
            int length=unique(positions,positions+6)-positions;
            auto remove=[&](){ for(int j=0;j<length;j++) {int p=positions[j]; score-=--counts[ids[row[p]][row[(p+n-1)%n]][row[(p+1)%n]]];} };
            auto add=[&](){ for(int j=0;j<length;j++) {int p=positions[j]; score+=counts[ids[row[p]][row[(p+n-1)%n]][row[(p+1)%n]]]++;} };
            int old=score;
            remove(); swap(row[a],row[b]); add();
            double temp=0.6*pow(0.08/0.6,double(step)/3000000);
            if(score>old && unit(rng)>exp((old-score)/temp)) {
                remove(); swap(row[a],row[b]); add();
            }
            if(score<best) { best=score; if(best<=5) cerr<<"n="<<n<<" best="<<best<<" seconds="<<elapsed()<<'\n'; }
        }
    }
    cerr<<"TIMEOUT n="<<n<<" best="<<best<<" seconds="<<elapsed()<<"\n";
    return 2;
}
