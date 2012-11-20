Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 998196B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:20:05 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4408710pbc.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 00:20:04 -0800 (PST)
Date: Tue, 20 Nov 2012 00:20:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
In-Reply-To: <20121120074445.GA14539@gmail.com>
Message-ID: <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com> <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com> <20121120060014.GA14065@gmail.com>
 <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com> <20121120074445.GA14539@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, 20 Nov 2012, Ingo Molnar wrote:

> > This happened to be an Opteron (but not 83xx series), 2.4Ghz.  
> 
> Ok - roughly which family/model from /proc/cpuinfo?
> 

It's close enough, it's 23xx.

> > It's perf top -U, the benchmark itself was unchanged so I 
> > didn't think it was interesting to gather the user symbols.  
> > If that would be helpful, let me know!
> 
> Yeah, regular perf top output would be very helpful to get a 
> general sense of proportion. Thanks!
> 

Ok, here it is:

    91.24%  perf-10971.map    [.] 0x00007f116a6c6fb8                            
     1.19%  libjvm.so         [.] instanceKlass::oop_push_contents(PSPromotionMa
     1.04%  libjvm.so         [.] PSPromotionManager::drain_stacks_depth(bool)  
     0.79%  libjvm.so         [.] PSPromotionManager::copy_to_survivor_space(oop
     0.60%  libjvm.so         [.] PSPromotionManager::claim_or_forward_internal_
     0.58%  [kernel]          [k] page_fault                                    
     0.28%  libc-2.3.6.so     [.] __gettimeofday                                        
     0.26%  libjvm.so         [.] Copy::pd_disjoint_words(HeapWord*, HeapWord*, unsigned
     0.22%  [kernel]          [k] getnstimeofday                                        
     0.18%  libjvm.so         [.] CardTableExtension::scavenge_contents_parallel(ObjectS
     0.15%  [kernel]          [k] _raw_spin_lock                                        
     0.12%  [kernel]          [k] ktime_get_update_offsets                              
     0.11%  [kernel]          [k] ktime_get                                             
     0.11%  [kernel]          [k] rcu_check_callbacks                                   
     0.10%  [kernel]          [k] generic_smp_call_function_interrupt                   
     0.10%  [kernel]          [k] read_tsc                                              
     0.10%  [kernel]          [k] clear_page_c                                          
     0.10%  [kernel]          [k] __do_page_fault                                       
     0.08%  [kernel]          [k] handle_mm_fault                                       
     0.08%  libjvm.so         [.] os::javaTimeMillis()                                  
     0.08%  [kernel]          [k] emulate_vsyscall                                      
     0.08%  [kernel]          [k] flush_tlb_func                                        
     0.07%  [kernel]          [k] task_tick_fair                                        
     0.07%  [kernel]          [k] retint_swapgs                                         
     0.06%  libjvm.so         [.] oopDesc::size_given_klass(Klass*)                     
     0.05%  [kernel]          [k] handle_pte_fault                                      
     0.05%  perf              [.] 0x0000000000033190                                    
     0.05%  sanctuaryd        [.] 0x00000000006f0ad3                                    
     0.05%  [kernel]          [k] copy_user_generic_string                              
     0.05%  libjvm.so         [.] objArrayKlass::oop_push_contents(PSPromotionManager*, 
     0.04%  [kernel]          [k] find_vma                                              
     0.04%  [kernel]          [k] mpol_misplaced                                        
     0.04%  [kernel]          [k] __bad_area_nosemaphore                                
     0.04%  [kernel]          [k] get_vma_policy                                        
     0.04%  [kernel]          [k] task_numa_fault                                       
     0.04%  [kernel]          [k] error_sti                                             
     0.03%  [kernel]          [k] write_ok_or_segv                                      
     0.03%  [kernel]          [k] do_gettimeofday                                       
     0.03%  [kernel]          [k] down_read_trylock                                     
     0.03%  [kernel]          [k] update_cfs_shares                                     
     0.03%  [kernel]          [k] error_entry                                           
     0.03%  [kernel]          [k] run_timer_softirq

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
