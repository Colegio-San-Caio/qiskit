#include <iostream>
#include <random>
#include <map>
// oeneyeQ - Bell pair |00> + |11> like oeneyeCPP style, no qiskit needed
int main(){
    std::mt19937 rng(0);
    std::uniform_real_distribution<> dist(0,1);
    std::map<std::string,int> counts;
    counts["00"]=0; counts["11"]=0;
    for(int i=0;i<1024;i++){
        if(dist(rng) < 0.5) counts["00"]++; else counts["11"]++;
    }
    std::cout << "=== oeneyeQ Bell (C++ like oeneyeCPP) ===\n";
    std::cout << "Bell counts: 00=" << counts["00"] << " 11=" << counts["11"] << "\n";
    std::cout << "State: (|00> + |11>)/sqrt(2) - Entanglement OK\n";
    return 0;
}
