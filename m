Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00DBE6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 05:16:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z20-v6so6281185pgv.17
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:16:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k5-v6si12024964plt.178.2018.06.19.02.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 02:16:43 -0700 (PDT)
Date: Tue, 19 Jun 2018 17:16:25 +0800
From: Haiyan Song <haiyanx.song@intel.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
Message-ID: <20180619091625.jfj7qwueisddas2h@haiyan.lkp.sh.intel.com>
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B834B67@SHSMSX101.ccr.corp.intel.com>
 <1327633f-8bb9-99f7-fab4-4cfcbf997200@linux.vnet.ibm.com>
 <20180528082235.e5x4oiaaf7cjoddr@haiyan.lkp.sh.intel.com>
 <316c6936-203d-67e9-c18c-6cf10d0d4bee@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B847F54@SHSMSX101.ccr.corp.intel.com>
 <b13302ab-da49-22a4-eda7-68a6528fb9e7@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="eh3qi5staxrvatcj"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b13302ab-da49-22a4-eda7-68a6528fb9e7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "kirill@shutemov.name" <kirill@shutemov.name>, "ak@linux.intel.com" <ak@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "jack@suse.cz" <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "paulus@samba.org" <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "sergey.senozhatsky.work@gmail.com" <sergey.senozhatsky.work@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, "Wang, Kemi" <kemi.wang@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "haren@linux.vnet.ibm.com" <haren@linux.vnet.ibm.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "x86@kernel.org" <x86@kernel.org>


--eh3qi5staxrvatcj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 11, 2018 at 05:15:22PM +0200, Laurent Dufour wrote:

Hi Laurent,

For perf date tested on Intel 4s Skylake platform, here attached the compare result
between base and head commit in attachment, which include the perf-profile comparision information.

And also attached some perf-profile.json captured from test result for page_fault2 and page_fault3 for
checking the regression, thanks.


Best regards,
Haiyan Song



> Hi Haiyan,
> 
> I don't have access to the same hardware you ran the test on, but I give a try
> to those test on a Power8 system (2 sockets, 5 cores/s, 8 threads/c, 80 CPUs 32G).
> I run each will-it-scale test 10 times and compute the average.
> 
> test THP enabled		4.17.0-rc4-mm1	spf		delta
> page_fault3_threads		2697.7		2683.5		-0.53%
> page_fault2_threads		170660.6	169574.1	-0.64%
> context_switch1_threads		6915269.2	6877507.3	-0.55%
> context_switch1_processes	6478076.2	6529493.5	0.79%
> rk1				243391.2	238527.5	-2.00%
> 
> Test were launched with the arguments '-t 80 -s 5', only the average report is
> taken in account. Note that page size is 64K by default on ppc64.
> 
> It would be nice if you could capture some perf data to figure out why the
> page_fault2/3 are showing such a performance regression.
> 
> Thanks,
> Laurent.
> 
> On 11/06/2018 09:49, Song, HaiyanX wrote:
> > Hi Laurent,
> > 
> > Regression test for v11 patch serials have been run, some regression is found by LKP-tools (linux kernel performance)
> > tested on Intel 4s skylake platform. This time only test the cases which have been run and found regressions on
> > V9 patch serials.
> > 
> > The regression result is sorted by the metric will-it-scale.per_thread_ops.
> > branch: Laurent-Dufour/Speculative-page-faults/20180520-045126
> > commit id:
> >   head commit : a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12
> >   base commit : ba98a1cdad71d259a194461b3a61471b49b14df1
> > Benchmark: will-it-scale
> > Download link: https://github.com/antonblanchard/will-it-scale/tree/master
> > 
> > Metrics:
> >   will-it-scale.per_process_ops=processes/nr_cpu
> >   will-it-scale.per_thread_ops=threads/nr_cpu
> >   test box: lkp-skl-4sp1(nr_cpu=192,memory=768G)
> > THP: enable / disable
> > nr_task:100%
> > 
> > 1. Regressions:
> > 
> > a). Enable THP
> > testcase                          base           change      head           metric
> > page_fault3/enable THP           10519          -20.5%       8368      will-it-scale.per_thread_ops
> > page_fault2/enalbe THP            8281          -18.8%       6728      will-it-scale.per_thread_ops
> > brk1/eanble THP                 998475           -2.2%     976893      will-it-scale.per_process_ops
> > context_switch1/enable THP      223910           -1.3%     220930      will-it-scale.per_process_ops
> > context_switch1/enable THP      233722           -1.0%     231288      will-it-scale.per_thread_ops
> > 
> > b). Disable THP
> > page_fault3/disable THP          10856          -23.1%       8344      will-it-scale.per_thread_ops
> > page_fault2/disable THP           8147          -18.8%       6613      will-it-scale.per_thread_ops
> > brk1/disable THP                   957           -7.9%        881      will-it-scale.per_thread_ops
> > context_switch1/disable THP     237006           -2.2%     231907      will-it-scale.per_thread_ops
> > brk1/disable THP                997317           -2.0%     977778      will-it-scale.per_process_ops
> > page_fault3/disable THP         467454           -1.8%     459251      will-it-scale.per_process_ops
> > context_switch1/disable THP     224431           -1.3%     221567      will-it-scale.per_process_ops
> > 
> > Notes: for the above  values of test result, the higher is better.
> > 
> > 2. Improvement: not found improvement based on the selected test cases.
> > 
> > 
> > Best regards
> > Haiyan Song
> > ________________________________________
> > From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of Laurent Dufour [ldufour@linux.vnet.ibm.com]
> > Sent: Monday, May 28, 2018 4:54 PM
> > To: Song, HaiyanX
> > Cc: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.com; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; sergey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minchan Kim; Punit Agrawal; vinayak menon; Yang Shi; linux-kernel@vger.kernel.org; linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingharora@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.ozlabs.org; x86@kernel.org
> > Subject: Re: [PATCH v11 00/26] Speculative page faults
> > 
> > On 28/05/2018 10:22, Haiyan Song wrote:
> >> Hi Laurent,
> >>
> >> Yes, these tests are done on V9 patch.
> > 
> > Do you plan to give this V11 a run ?
> > 
> >>
> >>
> >> Best regards,
> >> Haiyan Song
> >>
> >> On Mon, May 28, 2018 at 09:51:34AM +0200, Laurent Dufour wrote:
> >>> On 28/05/2018 07:23, Song, HaiyanX wrote:
> >>>>
> >>>> Some regression and improvements is found by LKP-tools(linux kernel performance) on V9 patch series
> >>>> tested on Intel 4s Skylake platform.
> >>>
> >>> Hi,
> >>>
> >>> Thanks for reporting this benchmark results, but you mentioned the "V9 patch
> >>> series" while responding to the v11 header series...
> >>> Were these tests done on v9 or v11 ?
> >>>
> >>> Cheers,
> >>> Laurent.
> >>>
> >>>>
> >>>> The regression result is sorted by the metric will-it-scale.per_thread_ops.
> >>>> Branch: Laurent-Dufour/Speculative-page-faults/20180316-151833 (V9 patch series)
> >>>> Commit id:
> >>>>     base commit: d55f34411b1b126429a823d06c3124c16283231f
> >>>>     head commit: 0355322b3577eeab7669066df42c550a56801110
> >>>> Benchmark suite: will-it-scale
> >>>> Download link:
> >>>> https://github.com/antonblanchard/will-it-scale/tree/master/tests
> >>>> Metrics:
> >>>>     will-it-scale.per_process_ops=processes/nr_cpu
> >>>>     will-it-scale.per_thread_ops=threads/nr_cpu
> >>>> test box: lkp-skl-4sp1(nr_cpu=192,memory=768G)
> >>>> THP: enable / disable
> >>>> nr_task: 100%
> >>>>
> >>>> 1. Regressions:
> >>>> a) THP enabled:
> >>>> testcase                        base            change          head       metric
> >>>> page_fault3/ enable THP         10092           -17.5%          8323       will-it-scale.per_thread_ops
> >>>> page_fault2/ enable THP          8300           -17.2%          6869       will-it-scale.per_thread_ops
> >>>> brk1/ enable THP                  957.67         -7.6%           885       will-it-scale.per_thread_ops
> >>>> page_fault3/ enable THP        172821            -5.3%        163692       will-it-scale.per_process_ops
> >>>> signal1/ enable THP              9125            -3.2%          8834       will-it-scale.per_process_ops
> >>>>
> >>>> b) THP disabled:
> >>>> testcase                        base            change          head       metric
> >>>> page_fault3/ disable THP        10107           -19.1%          8180       will-it-scale.per_thread_ops
> >>>> page_fault2/ disable THP         8432           -17.8%          6931       will-it-scale.per_thread_ops
> >>>> context_switch1/ disable THP   215389            -6.8%        200776       will-it-scale.per_thread_ops
> >>>> brk1/ disable THP                 939.67         -6.6%           877.33    will-it-scale.per_thread_ops
> >>>> page_fault3/ disable THP       173145            -4.7%        165064       will-it-scale.per_process_ops
> >>>> signal1/ disable THP             9162            -3.9%          8802       will-it-scale.per_process_ops
> >>>>
> >>>> 2. Improvements:
> >>>> a) THP enabled:
> >>>> testcase                        base            change          head       metric
> >>>> malloc1/ enable THP               66.33        +469.8%           383.67    will-it-scale.per_thread_ops
> >>>> writeseek3/ enable THP          2531             +4.5%          2646       will-it-scale.per_thread_ops
> >>>> signal1/ enable THP              989.33          +2.8%          1016       will-it-scale.per_thread_ops
> >>>>
> >>>> b) THP disabled:
> >>>> testcase                        base            change          head       metric
> >>>> malloc1/ disable THP              90.33        +417.3%           467.33    will-it-scale.per_thread_ops
> >>>> read2/ disable THP             58934            +39.2%         82060       will-it-scale.per_thread_ops
> >>>> page_fault1/ disable THP        8607            +36.4%         11736       will-it-scale.per_thread_ops
> >>>> read1/ disable THP            314063            +12.7%        353934       will-it-scale.per_thread_ops
> >>>> writeseek3/ disable THP         2452            +12.5%          2759       will-it-scale.per_thread_ops
> >>>> signal1/ disable THP             971.33          +5.5%          1024       will-it-scale.per_thread_ops
> >>>>
> >>>> Notes: for above values in column "change", the higher value means that the related testcase result
> >>>> on head commit is better than that on base commit for this benchmark.
> >>>>
> >>>>
> >>>> Best regards
> >>>> Haiyan Song
> >>>>
> >>>> ________________________________________
> >>>> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of Laurent Dufour [ldufour@linux.vnet.ibm.com]
> >>>> Sent: Thursday, May 17, 2018 7:06 PM
> >>>> To: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.com; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; sergey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minchan Kim; Punit Agrawal; vinayak menon; Yang Shi
> >>>> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingharora@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.ozlabs.org; x86@kernel.org
> >>>> Subject: [PATCH v11 00/26] Speculative page faults
> >>>>
> >>>> This is a port on kernel 4.17 of the work done by Peter Zijlstra to handle
> >>>> page fault without holding the mm semaphore [1].
> >>>>
> >>>> The idea is to try to handle user space page faults without holding the
> >>>> mmap_sem. This should allow better concurrency for massively threaded
> >>>> process since the page fault handler will not wait for other threads memory
> >>>> layout change to be done, assuming that this change is done in another part
> >>>> of the process's memory space. This type page fault is named speculative
> >>>> page fault. If the speculative page fault fails because of a concurrency is
> >>>> detected or because underlying PMD or PTE tables are not yet allocating, it
> >>>> is failing its processing and a classic page fault is then tried.
> >>>>
> >>>> The speculative page fault (SPF) has to look for the VMA matching the fault
> >>>> address without holding the mmap_sem, this is done by introducing a rwlock
> >>>> which protects the access to the mm_rb tree. Previously this was done using
> >>>> SRCU but it was introducing a lot of scheduling to process the VMA's
> >>>> freeing operation which was hitting the performance by 20% as reported by
> >>>> Kemi Wang [2]. Using a rwlock to protect access to the mm_rb tree is
> >>>> limiting the locking contention to these operations which are expected to
> >>>> be in a O(log n) order. In addition to ensure that the VMA is not freed in
> >>>> our back a reference count is added and 2 services (get_vma() and
> >>>> put_vma()) are introduced to handle the reference count. Once a VMA is
> >>>> fetched from the RB tree using get_vma(), it must be later freed using
> >>>> put_vma(). I can't see anymore the overhead I got while will-it-scale
> >>>> benchmark anymore.
> >>>>
> >>>> The VMA's attributes checked during the speculative page fault processing
> >>>> have to be protected against parallel changes. This is done by using a per
> >>>> VMA sequence lock. This sequence lock allows the speculative page fault
> >>>> handler to fast check for parallel changes in progress and to abort the
> >>>> speculative page fault in that case.
> >>>>
> >>>> Once the VMA has been found, the speculative page fault handler would check
> >>>> for the VMA's attributes to verify that the page fault has to be handled
> >>>> correctly or not. Thus, the VMA is protected through a sequence lock which
> >>>> allows fast detection of concurrent VMA changes. If such a change is
> >>>> detected, the speculative page fault is aborted and a *classic* page fault
> >>>> is tried.  VMA sequence lockings are added when VMA attributes which are
> >>>> checked during the page fault are modified.
> >>>>
> >>>> When the PTE is fetched, the VMA is checked to see if it has been changed,
> >>>> so once the page table is locked, the VMA is valid, so any other changes
> >>>> leading to touching this PTE will need to lock the page table, so no
> >>>> parallel change is possible at this time.
> >>>>
> >>>> The locking of the PTE is done with interrupts disabled, this allows
> >>>> checking for the PMD to ensure that there is not an ongoing collapsing
> >>>> operation. Since khugepaged is firstly set the PMD to pmd_none and then is
> >>>> waiting for the other CPU to have caught the IPI interrupt, if the pmd is
> >>>> valid at the time the PTE is locked, we have the guarantee that the
> >>>> collapsing operation will have to wait on the PTE lock to move forward.
> >>>> This allows the SPF handler to map the PTE safely. If the PMD value is
> >>>> different from the one recorded at the beginning of the SPF operation, the
> >>>> classic page fault handler will be called to handle the operation while
> >>>> holding the mmap_sem. As the PTE lock is done with the interrupts disabled,
> >>>> the lock is done using spin_trylock() to avoid dead lock when handling a
> >>>> page fault while a TLB invalidate is requested by another CPU holding the
> >>>> PTE.
> >>>>
> >>>> In pseudo code, this could be seen as:
> >>>>     speculative_page_fault()
> >>>>     {
> >>>>             vma = get_vma()
> >>>>             check vma sequence count
> >>>>             check vma's support
> >>>>             disable interrupt
> >>>>                   check pgd,p4d,...,pte
> >>>>                   save pmd and pte in vmf
> >>>>                   save vma sequence counter in vmf
> >>>>             enable interrupt
> >>>>             check vma sequence count
> >>>>             handle_pte_fault(vma)
> >>>>                     ..
> >>>>                     page = alloc_page()
> >>>>                     pte_map_lock()
> >>>>                             disable interrupt
> >>>>                                     abort if sequence counter has changed
> >>>>                                     abort if pmd or pte has changed
> >>>>                                     pte map and lock
> >>>>                             enable interrupt
> >>>>                     if abort
> >>>>                        free page
> >>>>                        abort
> >>>>                     ...
> >>>>     }
> >>>>
> >>>>     arch_fault_handler()
> >>>>     {
> >>>>             if (speculative_page_fault(&vma))
> >>>>                goto done
> >>>>     again:
> >>>>             lock(mmap_sem)
> >>>>             vma = find_vma();
> >>>>             handle_pte_fault(vma);
> >>>>             if retry
> >>>>                unlock(mmap_sem)
> >>>>                goto again;
> >>>>     done:
> >>>>             handle fault error
> >>>>     }
> >>>>
> >>>> Support for THP is not done because when checking for the PMD, we can be
> >>>> confused by an in progress collapsing operation done by khugepaged. The
> >>>> issue is that pmd_none() could be true either if the PMD is not already
> >>>> populated or if the underlying PTE are in the way to be collapsed. So we
> >>>> cannot safely allocate a PMD if pmd_none() is true.
> >>>>
> >>>> This series add a new software performance event named 'speculative-faults'
> >>>> or 'spf'. It counts the number of successful page fault event handled
> >>>> speculatively. When recording 'faults,spf' events, the faults one is
> >>>> counting the total number of page fault events while 'spf' is only counting
> >>>> the part of the faults processed speculatively.
> >>>>
> >>>> There are some trace events introduced by this series. They allow
> >>>> identifying why the page faults were not processed speculatively. This
> >>>> doesn't take in account the faults generated by a monothreaded process
> >>>> which directly processed while holding the mmap_sem. This trace events are
> >>>> grouped in a system named 'pagefault', they are:
> >>>>  - pagefault:spf_vma_changed : if the VMA has been changed in our back
> >>>>  - pagefault:spf_vma_noanon : the vma->anon_vma field was not yet set.
> >>>>  - pagefault:spf_vma_notsup : the VMA's type is not supported
> >>>>  - pagefault:spf_vma_access : the VMA's access right are not respected
> >>>>  - pagefault:spf_pmd_changed : the upper PMD pointer has changed in our
> >>>>    back.
> >>>>
> >>>> To record all the related events, the easier is to run perf with the
> >>>> following arguments :
> >>>> $ perf stat -e 'faults,spf,pagefault:*' <command>
> >>>>
> >>>> There is also a dedicated vmstat counter showing the number of successful
> >>>> page fault handled speculatively. I can be seen this way:
> >>>> $ grep speculative_pgfault /proc/vmstat
> >>>>
> >>>> This series builds on top of v4.16-mmotm-2018-04-13-17-28 and is functional
> >>>> on x86, PowerPC and arm64.
> >>>>
> >>>> ---------------------
> >>>> Real Workload results
> >>>>
> >>>> As mentioned in previous email, we did non official runs using a "popular
> >>>> in memory multithreaded database product" on 176 cores SMT8 Power system
> >>>> which showed a 30% improvements in the number of transaction processed per
> >>>> second. This run has been done on the v6 series, but changes introduced in
> >>>> this new version should not impact the performance boost seen.
> >>>>
> >>>> Here are the perf data captured during 2 of these runs on top of the v8
> >>>> series:
> >>>>                 vanilla         spf
> >>>> faults          89.418          101.364         +13%
> >>>> spf                n/a           97.989
> >>>>
> >>>> With the SPF kernel, most of the page fault were processed in a speculative
> >>>> way.
> >>>>
> >>>> Ganesh Mahendran had backported the series on top of a 4.9 kernel and gave
> >>>> it a try on an android device. He reported that the application launch time
> >>>> was improved in average by 6%, and for large applications (~100 threads) by
> >>>> 20%.
> >>>>
> >>>> Here are the launch time Ganesh mesured on Android 8.0 on top of a Qcom
> >>>> MSM845 (8 cores) with 6GB (the less is better):
> >>>>
> >>>> Application                             4.9     4.9+spf delta
> >>>> com.tencent.mm                          416     389     -7%
> >>>> com.eg.android.AlipayGphone             1135    986     -13%
> >>>> com.tencent.mtt                         455     454     0%
> >>>> com.qqgame.hlddz                        1497    1409    -6%
> >>>> com.autonavi.minimap                    711     701     -1%
> >>>> com.tencent.tmgp.sgame                  788     748     -5%
> >>>> com.immomo.momo                         501     487     -3%
> >>>> com.tencent.peng                        2145    2112    -2%
> >>>> com.smile.gifmaker                      491     461     -6%
> >>>> com.baidu.BaiduMap                      479     366     -23%
> >>>> com.taobao.taobao                       1341    1198    -11%
> >>>> com.baidu.searchbox                     333     314     -6%
> >>>> com.tencent.mobileqq                    394     384     -3%
> >>>> com.sina.weibo                          907     906     0%
> >>>> com.youku.phone                         816     731     -11%
> >>>> com.happyelements.AndroidAnimal.qq      763     717     -6%
> >>>> com.UCMobile                            415     411     -1%
> >>>> com.tencent.tmgp.ak                     1464    1431    -2%
> >>>> com.tencent.qqmusic                     336     329     -2%
> >>>> com.sankuai.meituan                     1661    1302    -22%
> >>>> com.netease.cloudmusic                  1193    1200    1%
> >>>> air.tv.douyu.android                    4257    4152    -2%
> >>>>
> >>>> ------------------
> >>>> Benchmarks results
> >>>>
> >>>> Base kernel is v4.17.0-rc4-mm1
> >>>> SPF is BASE + this series
> >>>>
> >>>> Kernbench:
> >>>> ----------
> >>>> Here are the results on a 16 CPUs X86 guest using kernbench on a 4.15
> >>>> kernel (kernel is build 5 times):
> >>>>
> >>>> Average Half load -j 8
> >>>>                  Run    (std deviation)
> >>>>                  BASE                   SPF
> >>>> Elapsed Time     1448.65 (5.72312)      1455.84 (4.84951)       0.50%
> >>>> User    Time     10135.4 (30.3699)      10148.8 (31.1252)       0.13%
> >>>> System  Time     900.47  (2.81131)      923.28  (7.52779)       2.53%
> >>>> Percent CPU      761.4   (1.14018)      760.2   (0.447214)      -0.16%
> >>>> Context Switches 85380   (3419.52)      84748   (1904.44)       -0.74%
> >>>> Sleeps           105064  (1240.96)      105074  (337.612)       0.01%
> >>>>
> >>>> Average Optimal load -j 16
> >>>>                  Run    (std deviation)
> >>>>                  BASE                   SPF
> >>>> Elapsed Time     920.528 (10.1212)      927.404 (8.91789)       0.75%
> >>>> User    Time     11064.8 (981.142)      11085   (990.897)       0.18%
> >>>> System  Time     979.904 (84.0615)      1001.14 (82.5523)       2.17%
> >>>> Percent CPU      1089.5  (345.894)      1086.1  (343.545)       -0.31%
> >>>> Context Switches 159488  (78156.4)      158223  (77472.1)       -0.79%
> >>>> Sleeps           110566  (5877.49)      110388  (5617.75)       -0.16%
> >>>>
> >>>>
> >>>> During a run on the SPF, perf events were captured:
> >>>>  Performance counter stats for '../kernbench -M':
> >>>>          526743764      faults
> >>>>                210      spf
> >>>>                  3      pagefault:spf_vma_changed
> >>>>                  0      pagefault:spf_vma_noanon
> >>>>               2278      pagefault:spf_vma_notsup
> >>>>                  0      pagefault:spf_vma_access
> >>>>                  0      pagefault:spf_pmd_changed
> >>>>
> >>>> Very few speculative page faults were recorded as most of the processes
> >>>> involved are monothreaded (sounds that on this architecture some threads
> >>>> were created during the kernel build processing).
> >>>>
> >>>> Here are the kerbench results on a 80 CPUs Power8 system:
> >>>>
> >>>> Average Half load -j 40
> >>>>                  Run    (std deviation)
> >>>>                  BASE                   SPF
> >>>> Elapsed Time     117.152 (0.774642)     117.166 (0.476057)      0.01%
> >>>> User    Time     4478.52 (24.7688)      4479.76 (9.08555)       0.03%
> >>>> System  Time     131.104 (0.720056)     134.04  (0.708414)      2.24%
> >>>> Percent CPU      3934    (19.7104)      3937.2  (19.0184)       0.08%
> >>>> Context Switches 92125.4 (576.787)      92581.6 (198.622)       0.50%
> >>>> Sleeps           317923  (652.499)      318469  (1255.59)       0.17%
> >>>>
> >>>> Average Optimal load -j 80
> >>>>                  Run    (std deviation)
> >>>>                  BASE                   SPF
> >>>> Elapsed Time     107.73  (0.632416)     107.31  (0.584936)      -0.39%
> >>>> User    Time     5869.86 (1466.72)      5871.71 (1467.27)       0.03%
> >>>> System  Time     153.728 (23.8573)      157.153 (24.3704)       2.23%
> >>>> Percent CPU      5418.6  (1565.17)      5436.7  (1580.91)       0.33%
> >>>> Context Switches 223861  (138865)       225032  (139632)        0.52%
> >>>> Sleeps           330529  (13495.1)      332001  (14746.2)       0.45%
> >>>>
> >>>> During a run on the SPF, perf events were captured:
> >>>>  Performance counter stats for '../kernbench -M':
> >>>>          116730856      faults
> >>>>                  0      spf
> >>>>                  3      pagefault:spf_vma_changed
> >>>>                  0      pagefault:spf_vma_noanon
> >>>>                476      pagefault:spf_vma_notsup
> >>>>                  0      pagefault:spf_vma_access
> >>>>                  0      pagefault:spf_pmd_changed
> >>>>
> >>>> Most of the processes involved are monothreaded so SPF is not activated but
> >>>> there is no impact on the performance.
> >>>>
> >>>> Ebizzy:
> >>>> -------
> >>>> The test is counting the number of records per second it can manage, the
> >>>> higher is the best. I run it like this 'ebizzy -mTt <nrcpus>'. To get
> >>>> consistent result I repeated the test 100 times and measure the average
> >>>> result. The number is the record processes per second, the higher is the
> >>>> best.
> >>>>
> >>>>                 BASE            SPF             delta
> >>>> 16 CPUs x86 VM  742.57          1490.24         100.69%
> >>>> 80 CPUs P8 node 13105.4         24174.23        84.46%
> >>>>
> >>>> Here are the performance counter read during a run on a 16 CPUs x86 VM:
> >>>>  Performance counter stats for './ebizzy -mTt 16':
> >>>>            1706379      faults
> >>>>            1674599      spf
> >>>>              30588      pagefault:spf_vma_changed
> >>>>                  0      pagefault:spf_vma_noanon
> >>>>                363      pagefault:spf_vma_notsup
> >>>>                  0      pagefault:spf_vma_access
> >>>>                  0      pagefault:spf_pmd_changed
> >>>>
> >>>> And the ones captured during a run on a 80 CPUs Power node:
> >>>>  Performance counter stats for './ebizzy -mTt 80':
> >>>>            1874773      faults
> >>>>            1461153      spf
> >>>>             413293      pagefault:spf_vma_changed
> >>>>                  0      pagefault:spf_vma_noanon
> >>>>                200      pagefault:spf_vma_notsup
> >>>>                  0      pagefault:spf_vma_access
> >>>>                  0      pagefault:spf_pmd_changed
> >>>>
> >>>> In ebizzy's case most of the page fault were handled in a speculative way,
> >>>> leading the ebizzy performance boost.
> >>>>
> >>>> ------------------
> >>>> Changes since v10 (https://lkml.org/lkml/2018/4/17/572):
> >>>>  - Accounted for all review feedbacks from Punit Agrawal, Ganesh Mahendran
> >>>>    and Minchan Kim, hopefully.
> >>>>  - Remove unneeded check on CONFIG_SPECULATIVE_PAGE_FAULT in
> >>>>    __do_page_fault().
> >>>>  - Loop in pte_spinlock() and pte_map_lock() when pte try lock fails
> >>>>    instead
> >>>>    of aborting the speculative page fault handling. Dropping the now
> >>>> useless
> >>>>    trace event pagefault:spf_pte_lock.
> >>>>  - No more try to reuse the fetched VMA during the speculative page fault
> >>>>    handling when retrying is needed. This adds a lot of complexity and
> >>>>    additional tests done didn't show a significant performance improvement.
> >>>>  - Convert IS_ENABLED(CONFIG_NUMA) back to #ifdef due to build error.
> >>>>
> >>>> [1] http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
> >>>> [2] https://patchwork.kernel.org/patch/9999687/
> >>>>
> >>>>
> >>>> Laurent Dufour (20):
> >>>>   mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
> >>>>   x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> >>>>   powerpc/mm: set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> >>>>   mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
> >>>>   mm: make pte_unmap_same compatible with SPF
> >>>>   mm: introduce INIT_VMA()
> >>>>   mm: protect VMA modifications using VMA sequence count
> >>>>   mm: protect mremap() against SPF hanlder
> >>>>   mm: protect SPF handler against anon_vma changes
> >>>>   mm: cache some VMA fields in the vm_fault structure
> >>>>   mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
> >>>>   mm: introduce __lru_cache_add_active_or_unevictable
> >>>>   mm: introduce __vm_normal_page()
> >>>>   mm: introduce __page_add_new_anon_rmap()
> >>>>   mm: protect mm_rb tree with a rwlock
> >>>>   mm: adding speculative page fault failure trace events
> >>>>   perf: add a speculative page fault sw event
> >>>>   perf tools: add support for the SPF perf event
> >>>>   mm: add speculative page fault vmstats
> >>>>   powerpc/mm: add speculative page fault
> >>>>
> >>>> Mahendran Ganesh (2):
> >>>>   arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> >>>>   arm64/mm: add speculative page fault
> >>>>
> >>>> Peter Zijlstra (4):
> >>>>   mm: prepare for FAULT_FLAG_SPECULATIVE
> >>>>   mm: VMA sequence count
> >>>>   mm: provide speculative fault infrastructure
> >>>>   x86/mm: add speculative pagefault handling
> >>>>
> >>>>  arch/arm64/Kconfig                    |   1 +
> >>>>  arch/arm64/mm/fault.c                 |  12 +
> >>>>  arch/powerpc/Kconfig                  |   1 +
> >>>>  arch/powerpc/mm/fault.c               |  16 +
> >>>>  arch/x86/Kconfig                      |   1 +
> >>>>  arch/x86/mm/fault.c                   |  27 +-
> >>>>  fs/exec.c                             |   2 +-
> >>>>  fs/proc/task_mmu.c                    |   5 +-
> >>>>  fs/userfaultfd.c                      |  17 +-
> >>>>  include/linux/hugetlb_inline.h        |   2 +-
> >>>>  include/linux/migrate.h               |   4 +-
> >>>>  include/linux/mm.h                    | 136 +++++++-
> >>>>  include/linux/mm_types.h              |   7 +
> >>>>  include/linux/pagemap.h               |   4 +-
> >>>>  include/linux/rmap.h                  |  12 +-
> >>>>  include/linux/swap.h                  |  10 +-
> >>>>  include/linux/vm_event_item.h         |   3 +
> >>>>  include/trace/events/pagefault.h      |  80 +++++
> >>>>  include/uapi/linux/perf_event.h       |   1 +
> >>>>  kernel/fork.c                         |   5 +-
> >>>>  mm/Kconfig                            |  22 ++
> >>>>  mm/huge_memory.c                      |   6 +-
> >>>>  mm/hugetlb.c                          |   2 +
> >>>>  mm/init-mm.c                          |   3 +
> >>>>  mm/internal.h                         |  20 ++
> >>>>  mm/khugepaged.c                       |   5 +
> >>>>  mm/madvise.c                          |   6 +-
> >>>>  mm/memory.c                           | 612 +++++++++++++++++++++++++++++-----
> >>>>  mm/mempolicy.c                        |  51 ++-
> >>>>  mm/migrate.c                          |   6 +-
> >>>>  mm/mlock.c                            |  13 +-
> >>>>  mm/mmap.c                             | 229 ++++++++++---
> >>>>  mm/mprotect.c                         |   4 +-
> >>>>  mm/mremap.c                           |  13 +
> >>>>  mm/nommu.c                            |   2 +-
> >>>>  mm/rmap.c                             |   5 +-
> >>>>  mm/swap.c                             |   6 +-
> >>>>  mm/swap_state.c                       |   8 +-
> >>>>  mm/vmstat.c                           |   5 +-
> >>>>  tools/include/uapi/linux/perf_event.h |   1 +
> >>>>  tools/perf/util/evsel.c               |   1 +
> >>>>  tools/perf/util/parse-events.c        |   4 +
> >>>>  tools/perf/util/parse-events.l        |   1 +
> >>>>  tools/perf/util/python.c              |   1 +
> >>>>  44 files changed, 1161 insertions(+), 211 deletions(-)
> >>>>  create mode 100644 include/trace/events/pagefault.h
> >>>>
> >>>> --
> >>>> 2.7.4
> >>>>
> >>>>
> >>>
> >>
> > 
> 

--eh3qi5staxrvatcj
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="compare-result.txt"
Content-Transfer-Encoding: 8bit

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/always/page_fault3/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
         44:3          -13%          43:3     perf-profile.calltrace.cycles-pp.error_entry
         22:3           -6%          22:3     perf-profile.calltrace.cycles-pp.sync_regs.error_entry
         44:3          -13%          44:3     perf-profile.children.cycles-pp.error_entry
         21:3           -7%          21:3     perf-profile.self.cycles-pp.error_entry
         %stddev     %change         %stddev
             \          |                \  
     10519 +-  3%     -20.5%       8368 +-  6%  will-it-scale.per_thread_ops
    118098           +11.2%     131287 +-  2%  will-it-scale.time.involuntary_context_switches
 6.084e+08 +-  3%     -20.4%  4.845e+08 +-  6%  will-it-scale.time.minor_page_faults
      7467            +5.0%       7841        will-it-scale.time.percent_of_cpu_this_job_got
     44922            +5.0%      47176        will-it-scale.time.system_time
   7126337 +-  3%     -15.4%    6025689 +-  6%  will-it-scale.time.voluntary_context_switches
  91905646            -1.3%   90673935        will-it-scale.workload
     27.15 +-  6%      -8.7%      24.80 +- 10%  boot-time.boot
   2516213 +-  6%      +8.3%    2726303        interrupts.CAL:Function_call_interrupts
    388.00 +-  9%     +60.2%     621.67 +- 20%  irq_exception_noise.softirq_nr
     11.28 +-  2%      -1.9        9.37 +-  4%  mpstat.cpu.idle%
     10065 +-140%    +243.4%      34559 +-  4%  numa-numastat.node0.other_node
     18739           -11.6%      16573 +-  3%  uptime.idle
     29406 +-  2%     -11.8%      25929 +-  5%  vmstat.system.cs
    329614 +-  8%     +17.0%     385618 +- 10%  meminfo.DirectMap4k
    237851           +21.2%     288160 +-  5%  meminfo.Inactive
    237615           +21.2%     287924 +-  5%  meminfo.Inactive(anon)
   7917847           -10.7%    7071860        softirqs.RCU
   4784181 +-  3%     -14.5%    4089039 +-  4%  softirqs.SCHED
  45666107 +-  7%     +12.9%   51535472 +-  3%  softirqs.TIMER
 2.617e+09 +-  2%     -13.9%  2.253e+09 +-  6%  cpuidle.C1E.time
   6688774 +-  2%     -12.8%    5835101 +-  5%  cpuidle.C1E.usage
 1.022e+10 +-  2%     -18.0%  8.376e+09 +-  3%  cpuidle.C6.time
  13440993 +-  2%     -16.3%   11243794 +-  4%  cpuidle.C6.usage
     54781 +- 16%     +37.5%      75347 +- 12%  numa-meminfo.node0.Inactive
     54705 +- 16%     +37.7%      75347 +- 12%  numa-meminfo.node0.Inactive(anon)
     52522           +35.0%      70886 +-  6%  numa-meminfo.node2.Inactive
     52443           +34.7%      70653 +-  6%  numa-meminfo.node2.Inactive(anon)
     31046 +-  6%     +30.3%      40457 +- 11%  numa-meminfo.node2.SReclaimable
     58563           +21.1%      70945 +-  6%  proc-vmstat.nr_inactive_anon
     58564           +21.1%      70947 +-  6%  proc-vmstat.nr_zone_inactive_anon
  69701118            -1.2%   68842151        proc-vmstat.pgalloc_normal
 2.765e+10            -1.3%  2.729e+10        proc-vmstat.pgfault
  69330418            -1.2%   68466824        proc-vmstat.pgfree
    118098           +11.2%     131287 +-  2%  time.involuntary_context_switches
 6.084e+08 +-  3%     -20.4%  4.845e+08 +-  6%  time.minor_page_faults
      7467            +5.0%       7841        time.percent_of_cpu_this_job_got
     44922            +5.0%      47176        time.system_time
   7126337 +-  3%     -15.4%    6025689 +-  6%  time.voluntary_context_switches
     13653 +- 16%     +33.5%      18225 +- 12%  numa-vmstat.node0.nr_inactive_anon
     13651 +- 16%     +33.5%      18224 +- 12%  numa-vmstat.node0.nr_zone_inactive_anon
     13069 +-  3%     +30.1%      17001 +-  4%  numa-vmstat.node2.nr_inactive_anon
    134.67 +- 42%     -49.5%      68.00 +- 31%  numa-vmstat.node2.nr_mlock
      7758 +-  6%     +30.4%      10112 +- 11%  numa-vmstat.node2.nr_slab_reclaimable
     13066 +-  3%     +30.1%      16998 +-  4%  numa-vmstat.node2.nr_zone_inactive_anon
      1039 +- 11%     -17.5%     857.33        slabinfo.Acpi-ParseExt.active_objs
      1039 +- 11%     -17.5%     857.33        slabinfo.Acpi-ParseExt.num_objs
      2566 +-  6%      -8.8%       2340 +-  5%  slabinfo.biovec-64.active_objs
      2566 +-  6%      -8.8%       2340 +-  5%  slabinfo.biovec-64.num_objs
    898.33 +-  3%      -9.5%     813.33 +-  3%  slabinfo.kmem_cache_node.active_objs
      1066 +-  2%      -8.0%     981.33 +-  3%  slabinfo.kmem_cache_node.num_objs
      1940            +2.3%       1984        turbostat.Avg_MHz
   6679037 +-  2%     -12.7%    5830270 +-  5%  turbostat.C1E
      2.25 +-  2%      -0.3        1.94 +-  6%  turbostat.C1E%
  13418115           -16.3%   11234510 +-  4%  turbostat.C6
      8.75 +-  2%      -1.6        7.18 +-  3%  turbostat.C6%
      5.99 +-  2%     -14.4%       5.13 +-  4%  turbostat.CPU%c1
      5.01 +-  3%     -20.1%       4.00 +-  4%  turbostat.CPU%c6
      1.77 +-  3%     -34.7%       1.15        turbostat.Pkg%pc2
 1.378e+13            +1.2%  1.394e+13        perf-stat.branch-instructions
      0.98            -0.0        0.94        perf-stat.branch-miss-rate%
 1.344e+11            -2.3%  1.313e+11        perf-stat.branch-misses
 1.076e+11            -1.8%  1.057e+11        perf-stat.cache-misses
 2.258e+11            -2.1%   2.21e+11        perf-stat.cache-references
  17788064 +-  2%     -11.9%   15674207 +-  6%  perf-stat.context-switches
 2.241e+14            +2.4%  2.294e+14        perf-stat.cpu-cycles
 1.929e+13            +2.2%  1.971e+13        perf-stat.dTLB-loads
      4.01            -0.2        3.83        perf-stat.dTLB-store-miss-rate%
 4.519e+11            -1.3%  4.461e+11        perf-stat.dTLB-store-misses
 1.082e+13            +3.6%  1.121e+13        perf-stat.dTLB-stores
  3.02e+10           +23.2%  3.721e+10 +-  3%  perf-stat.iTLB-load-misses
 2.721e+08 +-  8%      -8.8%  2.481e+08 +-  3%  perf-stat.iTLB-loads
 6.985e+13            +1.8%  7.111e+13        perf-stat.instructions
      2313           -17.2%       1914 +-  3%  perf-stat.instructions-per-iTLB-miss
 2.764e+10            -1.3%  2.729e+10        perf-stat.minor-faults
 1.421e+09 +-  2%     -16.4%  1.188e+09 +-  9%  perf-stat.node-load-misses
 1.538e+10            -9.3%  1.395e+10        perf-stat.node-loads
      9.75            +1.4       11.10        perf-stat.node-store-miss-rate%
 3.012e+09           +14.1%  3.437e+09        perf-stat.node-store-misses
 2.789e+10            -1.3%  2.753e+10        perf-stat.node-stores
 2.764e+10            -1.3%  2.729e+10        perf-stat.page-faults
    760059            +3.2%     784235        perf-stat.path-length
    193545 +- 25%     -57.8%      81757 +- 46%  sched_debug.cfs_rq:/.MIN_vruntime.avg
  26516863 +- 19%     -49.7%   13338070 +- 33%  sched_debug.cfs_rq:/.MIN_vruntime.max
   2202271 +- 21%     -53.2%    1029581 +- 38%  sched_debug.cfs_rq:/.MIN_vruntime.stddev
    193545 +- 25%     -57.8%      81757 +- 46%  sched_debug.cfs_rq:/.max_vruntime.avg
  26516863 +- 19%     -49.7%   13338070 +- 33%  sched_debug.cfs_rq:/.max_vruntime.max
   2202271 +- 21%     -53.2%    1029581 +- 38%  sched_debug.cfs_rq:/.max_vruntime.stddev
      0.32 +- 70%    +253.2%       1.14 +- 54%  sched_debug.cfs_rq:/.removed.load_avg.avg
      4.44 +- 70%    +120.7%       9.80 +- 27%  sched_debug.cfs_rq:/.removed.load_avg.stddev
     14.90 +- 70%    +251.0%      52.31 +- 53%  sched_debug.cfs_rq:/.removed.runnable_sum.avg
    205.71 +- 70%    +119.5%     451.60 +- 27%  sched_debug.cfs_rq:/.removed.runnable_sum.stddev
      0.16 +- 70%    +237.9%       0.54 +- 50%  sched_debug.cfs_rq:/.removed.util_avg.avg
      2.23 +- 70%    +114.2%       4.77 +- 24%  sched_debug.cfs_rq:/.removed.util_avg.stddev
    573.70 +-  5%      -9.7%     518.06 +-  6%  sched_debug.cfs_rq:/.util_avg.min
    114.87 +-  8%     +14.1%     131.04 +- 10%  sched_debug.cfs_rq:/.util_est_enqueued.avg
     64.42 +- 54%     -63.9%      23.27 +- 68%  sched_debug.cpu.cpu_load[1].max
      5.05 +- 48%     -55.2%       2.26 +- 51%  sched_debug.cpu.cpu_load[1].stddev
     57.58 +- 59%     -60.3%      22.88 +- 70%  sched_debug.cpu.cpu_load[2].max
     21019 +-  3%     -15.1%      17841 +-  6%  sched_debug.cpu.nr_switches.min
     20797 +-  3%     -15.0%      17670 +-  6%  sched_debug.cpu.sched_count.min
     10287 +-  3%     -15.1%       8736 +-  6%  sched_debug.cpu.sched_goidle.avg
     13693 +-  2%     -10.7%      12233 +-  5%  sched_debug.cpu.sched_goidle.max
      9976 +-  3%     -16.0%       8381 +-  7%  sched_debug.cpu.sched_goidle.min
      0.00 +- 26%     +98.9%       0.00 +- 28%  sched_debug.rt_rq:/.rt_time.min
      4230 +-141%    -100.0%       0.00        latency_stats.avg.trace_module_notify.notifier_call_chain.blocking_notifier_call_chain.do_init_module.load_module.__do_sys_finit_module.do_syscall_64.entry_SYSCALL_64_after_hwframe
     28498 +-141%    -100.0%       0.00        latency_stats.avg.perf_event_alloc.__do_sys_perf_event_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4065 +-138%     -92.2%     315.33 +- 91%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
      0.00       +3.6e+105%       3641 +-141%  latency_stats.avg.down.console_lock.console_device.tty_lookup_driver.tty_open.chrdev_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +2.5e+106%      25040 +-141%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +3.4e+106%      34015 +-141%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_get_acl.get_acl.posix_acl_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open
      0.00       +4.8e+106%      47686 +-141%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
      4230 +-141%    -100.0%       0.00        latency_stats.max.trace_module_notify.notifier_call_chain.blocking_notifier_call_chain.do_init_module.load_module.__do_sys_finit_module.do_syscall_64.entry_SYSCALL_64_after_hwframe
     28498 +-141%    -100.0%       0.00        latency_stats.max.perf_event_alloc.__do_sys_perf_event_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4065 +-138%     -92.2%     315.33 +- 91%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
      4254 +-134%     -88.0%     511.67 +- 90%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
     43093 +- 35%     +76.6%      76099 +-115%  latency_stats.max.blk_execute_rq.scsi_execute.ioctl_internal_command.scsi_set_medium_removal.cdrom_release.[cdrom].sr_block_release.[sr_mod].__blkdev_put.blkdev_close.__fput.task_work_run.exit_to_usermode_loop.do_syscall_64
     24139 +- 70%    +228.5%      79285 +-105%  latency_stats.max.blk_execute_rq.scsi_execute.scsi_test_unit_ready.sr_check_events.[sr_mod].cdrom_check_events.[cdrom].sr_block_check_events.[sr_mod].disk_check_events.disk_clear_events.check_disk_change.sr_block_open.[sr_mod].__blkdev_get.blkdev_get
      0.00       +3.6e+105%       3641 +-141%  latency_stats.max.down.console_lock.console_device.tty_lookup_driver.tty_open.chrdev_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +2.5e+106%      25040 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +3.4e+106%      34015 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_get_acl.get_acl.posix_acl_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open
      0.00       +6.5e+106%      64518 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
      4230 +-141%    -100.0%       0.00        latency_stats.sum.trace_module_notify.notifier_call_chain.blocking_notifier_call_chain.do_init_module.load_module.__do_sys_finit_module.do_syscall_64.entry_SYSCALL_64_after_hwframe
     28498 +-141%    -100.0%       0.00        latency_stats.sum.perf_event_alloc.__do_sys_perf_event_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4065 +-138%     -92.2%     315.33 +- 91%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
     57884 +-  9%     +47.3%      85264 +-118%  latency_stats.sum.blk_execute_rq.scsi_execute.ioctl_internal_command.scsi_set_medium_removal.cdrom_release.[cdrom].sr_block_release.[sr_mod].__blkdev_put.blkdev_close.__fput.task_work_run.exit_to_usermode_loop.do_syscall_64
      0.00       +3.6e+105%       3641 +-141%  latency_stats.sum.down.console_lock.console_device.tty_lookup_driver.tty_open.chrdev_open.do_dentry_open.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +2.5e+106%      25040 +-141%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +3.4e+106%      34015 +-141%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_get_acl.get_acl.posix_acl_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open
      0.00       +9.5e+106%      95373 +-141%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
     11.70           -11.7        0.00        perf-profile.calltrace.cycles-pp.__do_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
     11.52           -11.5        0.00        perf-profile.calltrace.cycles-pp.shmem_fault.__do_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
     10.44           -10.4        0.00        perf-profile.calltrace.cycles-pp.shmem_getpage_gfp.shmem_fault.__do_fault.__handle_mm_fault.handle_mm_fault
      9.83            -9.8        0.00        perf-profile.calltrace.cycles-pp.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault.__handle_mm_fault
      9.55            -9.5        0.00        perf-profile.calltrace.cycles-pp.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      9.35            -9.3        0.00        perf-profile.calltrace.cycles-pp.alloc_set_pte.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      6.81            -6.8        0.00        perf-profile.calltrace.cycles-pp.page_add_file_rmap.alloc_set_pte.finish_fault.__handle_mm_fault.handle_mm_fault
      7.71            -0.3        7.45        perf-profile.calltrace.cycles-pp.find_get_entry.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault
      0.59 +-  7%      -0.2        0.35 +- 70%  perf-profile.calltrace.cycles-pp.smp_apic_timer_interrupt.apic_timer_interrupt.__do_page_fault.do_page_fault.page_fault
      0.59 +-  7%      -0.2        0.35 +- 70%  perf-profile.calltrace.cycles-pp.apic_timer_interrupt.__do_page_fault.do_page_fault.page_fault
     10.41            -0.2       10.24        perf-profile.calltrace.cycles-pp.native_irq_return_iret
      7.68            -0.1        7.60        perf-profile.calltrace.cycles-pp.swapgs_restore_regs_and_return_to_usermode
      0.76            -0.1        0.70        perf-profile.calltrace.cycles-pp.down_read_trylock.__do_page_fault.do_page_fault.page_fault
      1.38            -0.0        1.34        perf-profile.calltrace.cycles-pp.do_page_fault
      1.05            -0.0        1.02        perf-profile.calltrace.cycles-pp.trace_graph_entry.do_page_fault
      0.92            +0.0        0.94        perf-profile.calltrace.cycles-pp.find_vma.__do_page_fault.do_page_fault.page_fault
      0.91            +0.0        0.93        perf-profile.calltrace.cycles-pp.vmacache_find.find_vma.__do_page_fault.do_page_fault.page_fault
      0.65            +0.0        0.67        perf-profile.calltrace.cycles-pp.set_page_dirty.unmap_page_range.unmap_vmas.unmap_region.do_munmap
      0.62            +0.0        0.66        perf-profile.calltrace.cycles-pp.page_mapping.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault
      4.15            +0.1        4.27        perf-profile.calltrace.cycles-pp.page_remove_rmap.unmap_page_range.unmap_vmas.unmap_region.do_munmap
     10.17            +0.2       10.39        perf-profile.calltrace.cycles-pp.munmap
      9.56            +0.2        9.78        perf-profile.calltrace.cycles-pp.entry_SYSCALL_64_after_hwframe.munmap
      9.56            +0.2        9.78        perf-profile.calltrace.cycles-pp.do_syscall_64.entry_SYSCALL_64_after_hwframe.munmap
      9.56            +0.2        9.78        perf-profile.calltrace.cycles-pp.unmap_region.do_munmap.vm_munmap.__x64_sys_munmap.do_syscall_64
      9.54            +0.2        9.76        perf-profile.calltrace.cycles-pp.unmap_page_range.unmap_vmas.unmap_region.do_munmap.vm_munmap
      9.54            +0.2        9.76        perf-profile.calltrace.cycles-pp.unmap_vmas.unmap_region.do_munmap.vm_munmap.__x64_sys_munmap
      9.56            +0.2        9.78        perf-profile.calltrace.cycles-pp.do_munmap.vm_munmap.__x64_sys_munmap.do_syscall_64.entry_SYSCALL_64_after_hwframe
      9.56            +0.2        9.78        perf-profile.calltrace.cycles-pp.vm_munmap.__x64_sys_munmap.do_syscall_64.entry_SYSCALL_64_after_hwframe.munmap
      9.56            +0.2        9.78        perf-profile.calltrace.cycles-pp.__x64_sys_munmap.do_syscall_64.entry_SYSCALL_64_after_hwframe.munmap
      0.00            +0.6        0.56 +-  2%  perf-profile.calltrace.cycles-pp.lock_page_memcg.page_add_file_rmap.alloc_set_pte.finish_fault.handle_pte_fault
      0.00            +0.6        0.59        perf-profile.calltrace.cycles-pp.page_mapping.set_page_dirty.fault_dirty_shared_page.handle_pte_fault.__handle_mm_fault
      0.00            +0.6        0.60        perf-profile.calltrace.cycles-pp.current_time.file_update_time.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +0.7        0.68        perf-profile.calltrace.cycles-pp.___might_sleep.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault
      0.00            +0.7        0.74        perf-profile.calltrace.cycles-pp.unlock_page.fault_dirty_shared_page.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +0.8        0.80        perf-profile.calltrace.cycles-pp.set_page_dirty.fault_dirty_shared_page.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +0.9        0.88        perf-profile.calltrace.cycles-pp._raw_spin_lock.pte_map_lock.alloc_set_pte.finish_fault.handle_pte_fault
      0.00            +0.9        0.91        perf-profile.calltrace.cycles-pp.__set_page_dirty_no_writeback.fault_dirty_shared_page.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +1.3        1.27        perf-profile.calltrace.cycles-pp.pte_map_lock.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault
      0.00            +1.3        1.30        perf-profile.calltrace.cycles-pp.file_update_time.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00            +2.8        2.76        perf-profile.calltrace.cycles-pp.fault_dirty_shared_page.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00            +6.8        6.81        perf-profile.calltrace.cycles-pp.page_add_file_rmap.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault
      0.00            +9.4        9.39        perf-profile.calltrace.cycles-pp.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +9.6        9.59        perf-profile.calltrace.cycles-pp.finish_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00            +9.8        9.77        perf-profile.calltrace.cycles-pp.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault.handle_pte_fault
      0.00           +10.4       10.37        perf-profile.calltrace.cycles-pp.shmem_getpage_gfp.shmem_fault.__do_fault.handle_pte_fault.__handle_mm_fault
      0.00           +11.5       11.46        perf-profile.calltrace.cycles-pp.shmem_fault.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00           +11.6       11.60        perf-profile.calltrace.cycles-pp.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00           +26.6       26.62        perf-profile.calltrace.cycles-pp.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      7.88            -0.3        7.61        perf-profile.children.cycles-pp.find_get_entry
      1.34 +-  8%      -0.2        1.16 +-  2%  perf-profile.children.cycles-pp.hrtimer_interrupt
     10.41            -0.2       10.24        perf-profile.children.cycles-pp.native_irq_return_iret
      0.38 +- 28%      -0.1        0.26 +-  4%  perf-profile.children.cycles-pp.tick_sched_timer
     11.80            -0.1       11.68        perf-profile.children.cycles-pp.__do_fault
      0.55 +- 15%      -0.1        0.43 +-  2%  perf-profile.children.cycles-pp.__hrtimer_run_queues
      0.60            -0.1        0.51        perf-profile.children.cycles-pp.pmd_devmap_trans_unstable
      0.38 +- 13%      -0.1        0.29 +-  4%  perf-profile.children.cycles-pp.ktime_get
      7.68            -0.1        7.60        perf-profile.children.cycles-pp.swapgs_restore_regs_and_return_to_usermode
      5.18            -0.1        5.12        perf-profile.children.cycles-pp.trace_graph_entry
      0.79            -0.1        0.73        perf-profile.children.cycles-pp.down_read_trylock
      7.83            -0.1        7.76        perf-profile.children.cycles-pp.sync_regs
      3.01            -0.1        2.94        perf-profile.children.cycles-pp.fault_dirty_shared_page
      1.02            -0.1        0.96        perf-profile.children.cycles-pp._raw_spin_lock
      4.66            -0.1        4.61        perf-profile.children.cycles-pp.prepare_ftrace_return
      0.37 +-  8%      -0.1        0.32 +-  3%  perf-profile.children.cycles-pp.current_kernel_time64
      5.26            -0.1        5.21        perf-profile.children.cycles-pp.ftrace_graph_caller
      0.66 +-  5%      -0.1        0.61        perf-profile.children.cycles-pp.current_time
      0.18 +-  5%      -0.0        0.15 +-  3%  perf-profile.children.cycles-pp.update_process_times
      0.27            -0.0        0.26        perf-profile.children.cycles-pp._cond_resched
      0.16            -0.0        0.15 +-  3%  perf-profile.children.cycles-pp.rcu_all_qs
      0.94            +0.0        0.95        perf-profile.children.cycles-pp.vmacache_find
      0.48            +0.0        0.50        perf-profile.children.cycles-pp.__mod_node_page_state
      0.17            +0.0        0.19 +-  2%  perf-profile.children.cycles-pp.__unlock_page_memcg
      1.07            +0.0        1.10        perf-profile.children.cycles-pp.find_vma
      0.79 +-  3%      +0.1        0.86 +-  2%  perf-profile.children.cycles-pp.lock_page_memcg
      4.29            +0.1        4.40        perf-profile.children.cycles-pp.page_remove_rmap
      1.39 +-  2%      +0.1        1.52        perf-profile.children.cycles-pp.file_update_time
      0.00            +0.2        0.16        perf-profile.children.cycles-pp.__vm_normal_page
      9.63            +0.2        9.84        perf-profile.children.cycles-pp.entry_SYSCALL_64_after_hwframe
      9.63            +0.2        9.84        perf-profile.children.cycles-pp.do_syscall_64
      9.63            +0.2        9.84        perf-profile.children.cycles-pp.unmap_page_range
     10.17            +0.2       10.39        perf-profile.children.cycles-pp.munmap
      9.56            +0.2        9.78        perf-profile.children.cycles-pp.unmap_region
      9.56            +0.2        9.78        perf-profile.children.cycles-pp.do_munmap
      9.56            +0.2        9.78        perf-profile.children.cycles-pp.vm_munmap
      9.56            +0.2        9.78        perf-profile.children.cycles-pp.__x64_sys_munmap
      9.54            +0.2        9.77        perf-profile.children.cycles-pp.unmap_vmas
      1.01            +0.2        1.25        perf-profile.children.cycles-pp.___might_sleep
      0.00            +1.6        1.59        perf-profile.children.cycles-pp.pte_map_lock
      0.00           +26.9       26.89        perf-profile.children.cycles-pp.handle_pte_fault
      4.25            -1.0        3.24        perf-profile.self.cycles-pp.__handle_mm_fault
      1.42            -0.3        1.11        perf-profile.self.cycles-pp.alloc_set_pte
      4.87            -0.3        4.59        perf-profile.self.cycles-pp.find_get_entry
     10.41            -0.2       10.24        perf-profile.self.cycles-pp.native_irq_return_iret
      0.37 +- 13%      -0.1        0.28 +-  4%  perf-profile.self.cycles-pp.ktime_get
      0.60            -0.1        0.51        perf-profile.self.cycles-pp.pmd_devmap_trans_unstable
      7.50            -0.1        7.42        perf-profile.self.cycles-pp.swapgs_restore_regs_and_return_to_usermode
      7.83            -0.1        7.76        perf-profile.self.cycles-pp.sync_regs
      4.85            -0.1        4.79        perf-profile.self.cycles-pp.trace_graph_entry
      1.01            -0.1        0.95        perf-profile.self.cycles-pp._raw_spin_lock
      0.78            -0.1        0.73        perf-profile.self.cycles-pp.down_read_trylock
      0.36 +-  9%      -0.1        0.31 +-  4%  perf-profile.self.cycles-pp.current_kernel_time64
      0.28            -0.0        0.23 +-  2%  perf-profile.self.cycles-pp.__do_fault
      1.04            -0.0        1.00        perf-profile.self.cycles-pp.find_lock_entry
      0.30            -0.0        0.28 +-  3%  perf-profile.self.cycles-pp.fault_dirty_shared_page
      0.70            -0.0        0.67        perf-profile.self.cycles-pp.prepare_ftrace_return
      0.44            -0.0        0.42        perf-profile.self.cycles-pp.do_page_fault
      0.16            -0.0        0.14        perf-profile.self.cycles-pp.rcu_all_qs
      0.78            -0.0        0.77        perf-profile.self.cycles-pp.shmem_getpage_gfp
      0.20            -0.0        0.19        perf-profile.self.cycles-pp._cond_resched
      0.50            +0.0        0.51        perf-profile.self.cycles-pp.set_page_dirty
      0.93            +0.0        0.95        perf-profile.self.cycles-pp.vmacache_find
      0.36 +-  2%      +0.0        0.38        perf-profile.self.cycles-pp.__might_sleep
      0.47            +0.0        0.50        perf-profile.self.cycles-pp.__mod_node_page_state
      0.17            +0.0        0.19 +-  2%  perf-profile.self.cycles-pp.__unlock_page_memcg
      2.34            +0.0        2.38        perf-profile.self.cycles-pp.unmap_page_range
      0.78 +-  3%      +0.1        0.85 +-  2%  perf-profile.self.cycles-pp.lock_page_memcg
      2.17            +0.1        2.24        perf-profile.self.cycles-pp.__do_page_fault
      0.00            +0.2        0.16 +-  3%  perf-profile.self.cycles-pp.__vm_normal_page
      1.00            +0.2        1.24        perf-profile.self.cycles-pp.___might_sleep
      0.00            +0.7        0.70        perf-profile.self.cycles-pp.pte_map_lock
      0.00            +1.4        1.42 +-  2%  perf-profile.self.cycles-pp.handle_pte_fault

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/never/context_switch1/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :3           33%           1:3     dmesg.WARNING:at#for_ip_interrupt_entry/0x
          2:3          -67%            :3     kmsg.pstore:crypto_comp_decompress_failed,ret=
          2:3          -67%            :3     kmsg.pstore:decompression_failed
         %stddev     %change         %stddev
             \          |                \  
    224431            -1.3%     221567        will-it-scale.per_process_ops
    237006            -2.2%     231907        will-it-scale.per_thread_ops
 1.601e+09 +- 29%     -46.9%  8.501e+08 +- 12%  will-it-scale.time.involuntary_context_switches
      5429            -1.6%       5344        will-it-scale.time.user_time
  88596221            -1.7%   87067269        will-it-scale.workload
      6863 +-  6%      -9.7%       6200        boot-time.idle
    144908 +- 40%     -66.8%      48173 +- 93%  meminfo.CmaFree
      0.00 +- 70%      +0.0        0.00        mpstat.cpu.iowait%
    448336 +- 14%     -34.8%     292125 +-  3%  turbostat.C1
      7684 +-  6%      -9.5%       6957        uptime.idle
 1.601e+09 +- 29%     -46.9%  8.501e+08 +- 12%  time.involuntary_context_switches
      5429            -1.6%       5344        time.user_time
  44013162            -1.7%   43243125        vmstat.system.cs
    207684            -1.1%     205485        vmstat.system.in
   2217033 +- 15%     -15.8%    1866876 +-  2%  cpuidle.C1.time
    451218 +- 14%     -34.7%     294841 +-  2%  cpuidle.C1.usage
     24839 +- 10%     -19.9%      19896        cpuidle.POLL.time
      7656 +- 11%     -38.9%       4676 +-  8%  cpuidle.POLL.usage
      5.48 +- 49%     -67.3%       1.79 +-100%  irq_exception_noise.__do_page_fault.95th
      9.46 +- 21%     -58.2%       3.95 +- 64%  irq_exception_noise.__do_page_fault.99th
     35.67 +-  8%   +1394.4%     533.00 +- 96%  irq_exception_noise.irq_nr
     52109 +-  3%     -16.0%      43784 +-  4%  irq_exception_noise.softirq_time
     36226 +- 40%     -66.7%      12048 +- 93%  proc-vmstat.nr_free_cma
     25916            -1.0%      25659        proc-vmstat.nr_slab_reclaimable
     16279 +-  8%   +2646.1%     447053 +- 82%  proc-vmstat.pgalloc_movable
   2231117           -18.4%    1820828 +- 20%  proc-vmstat.pgalloc_normal
   1109316 +- 46%     -86.9%     145207 +-109%  numa-numastat.node1.local_node
   1114700 +- 45%     -84.5%     172877 +- 85%  numa-numastat.node1.numa_hit
      5523 +-140%    +402.8%      27768 +- 39%  numa-numastat.node1.other_node
     29013 +- 29%   +3048.1%     913379 +- 73%  numa-numastat.node3.local_node
     65032 +- 13%   +1335.1%     933270 +- 70%  numa-numastat.node3.numa_hit
     36018           -44.8%      19897 +- 75%  numa-numastat.node3.other_node
     12.79 +- 21%   +7739.1%       1002 +-136%  sched_debug.cpu.cpu_load[1].max
      1.82 +- 10%   +3901.1%      72.92 +-135%  sched_debug.cpu.cpu_load[1].stddev
      1.71 +-  4%   +5055.8%      88.08 +-137%  sched_debug.cpu.cpu_load[2].stddev
     12.33 +- 23%   +9061.9%       1129 +-139%  sched_debug.cpu.cpu_load[3].max
      1.78 +- 10%   +4514.8%      82.18 +-137%  sched_debug.cpu.cpu_load[3].stddev
      4692 +- 72%    +154.5%      11945 +- 29%  sched_debug.cpu.max_idle_balance_cost.stddev
     23979            -8.3%      21983        slabinfo.kmalloc-96.active_objs
      1358 +-  6%     -17.9%       1114 +-  3%  slabinfo.nsproxy.active_objs
      1358 +-  6%     -17.9%       1114 +-  3%  slabinfo.nsproxy.num_objs
     15229           +12.4%      17119        slabinfo.pde_opener.active_objs
     15229           +12.4%      17119        slabinfo.pde_opener.num_objs
     59541 +-  8%     -10.1%      53537 +-  8%  slabinfo.vm_area_struct.active_objs
     59612 +-  8%     -10.1%      53604 +-  8%  slabinfo.vm_area_struct.num_objs
 4.163e+13            -1.4%  4.105e+13        perf-stat.branch-instructions
 6.537e+11            -1.2%  6.459e+11        perf-stat.branch-misses
 2.667e+10            -1.7%  2.621e+10        perf-stat.context-switches
      1.21            +1.3%       1.22        perf-stat.cpi
    150508            -9.8%     135825 +-  3%  perf-stat.cpu-migrations
      5.75 +- 33%      +5.4       11.11 +- 26%  perf-stat.iTLB-load-miss-rate%
 3.619e+09 +- 36%    +100.9%  7.272e+09 +- 30%  perf-stat.iTLB-load-misses
 2.089e+14            -1.3%  2.062e+14        perf-stat.instructions
     64607 +- 29%     -50.5%      31964 +- 37%  perf-stat.instructions-per-iTLB-miss
      0.83            -1.3%       0.82        perf-stat.ipc
      3972 +-  4%     -14.7%       3388 +-  8%  numa-meminfo.node0.PageTables
    207919 +- 25%     -57.2%      88989 +- 74%  numa-meminfo.node1.Active
    207715 +- 26%     -57.3%      88785 +- 74%  numa-meminfo.node1.Active(anon)
    356529           -34.3%     234069 +-  2%  numa-meminfo.node1.FilePages
    789129 +-  5%     -19.8%     633161 +- 12%  numa-meminfo.node1.MemUsed
     34777 +-  8%     -48.2%      18010 +- 30%  numa-meminfo.node1.SReclaimable
     69641 +-  4%     -20.7%      55250 +- 12%  numa-meminfo.node1.SUnreclaim
    125526 +-  4%     -96.3%       4602 +- 41%  numa-meminfo.node1.Shmem
    104419           -29.8%      73261 +- 16%  numa-meminfo.node1.Slab
    103661 +- 17%     -72.0%      29029 +- 99%  numa-meminfo.node2.Active
    103661 +- 17%     -72.2%      28829 +-101%  numa-meminfo.node2.Active(anon)
    103564 +- 18%     -72.0%      29007 +-100%  numa-meminfo.node2.AnonPages
    671654 +-  7%     -14.6%     573598 +-  4%  numa-meminfo.node2.MemUsed
     44206 +-127%    +301.4%     177465 +- 42%  numa-meminfo.node3.Active
     44206 +-127%    +301.0%     177263 +- 42%  numa-meminfo.node3.Active(anon)
      8738           +12.2%       9805 +-  8%  numa-meminfo.node3.KernelStack
    603605 +-  9%     +27.8%     771554 +- 14%  numa-meminfo.node3.MemUsed
     14438 +-  6%    +122.9%      32181 +- 42%  numa-meminfo.node3.SReclaimable
      2786 +-137%   +3302.0%      94792 +- 71%  numa-meminfo.node3.Shmem
     71461 +-  7%     +45.2%     103771 +- 29%  numa-meminfo.node3.Slab
    247197 +-  4%      -7.8%     227843        numa-meminfo.node3.Unevictable
    991.67 +-  4%     -14.7%     846.00 +-  8%  numa-vmstat.node0.nr_page_table_pages
     51926 +- 26%     -57.3%      22196 +- 74%  numa-vmstat.node1.nr_active_anon
     89137           -34.4%      58516 +-  2%  numa-vmstat.node1.nr_file_pages
      1679 +-  5%     -10.8%       1498 +-  4%  numa-vmstat.node1.nr_mapped
     31386 +-  4%     -96.3%       1150 +- 41%  numa-vmstat.node1.nr_shmem
      8694 +-  8%     -48.2%       4502 +- 30%  numa-vmstat.node1.nr_slab_reclaimable
     17410 +-  4%     -20.7%      13812 +- 12%  numa-vmstat.node1.nr_slab_unreclaimable
     51926 +- 26%     -57.3%      22196 +- 74%  numa-vmstat.node1.nr_zone_active_anon
   1037174 +- 24%     -57.0%     446205 +- 35%  numa-vmstat.node1.numa_hit
    961611 +- 26%     -65.8%     328687 +- 50%  numa-vmstat.node1.numa_local
     75563 +- 44%     +55.5%     117517 +-  9%  numa-vmstat.node1.numa_other
     25914 +- 17%     -72.2%       7206 +-101%  numa-vmstat.node2.nr_active_anon
     25891 +- 18%     -72.0%       7251 +-100%  numa-vmstat.node2.nr_anon_pages
     25914 +- 17%     -72.2%       7206 +-101%  numa-vmstat.node2.nr_zone_active_anon
     11051 +-127%    +301.0%      44309 +- 42%  numa-vmstat.node3.nr_active_anon
     36227 +- 40%     -66.7%      12049 +- 93%  numa-vmstat.node3.nr_free_cma
      0.33 +-141%  +25000.0%      83.67 +- 81%  numa-vmstat.node3.nr_inactive_file
      8739           +12.2%       9806 +-  8%  numa-vmstat.node3.nr_kernel_stack
    696.67 +-137%   +3299.7%      23684 +- 71%  numa-vmstat.node3.nr_shmem
      3609 +-  6%    +122.9%       8044 +- 42%  numa-vmstat.node3.nr_slab_reclaimable
     61799 +-  4%      -7.8%      56960        numa-vmstat.node3.nr_unevictable
     11053 +-127%    +301.4%      44361 +- 42%  numa-vmstat.node3.nr_zone_active_anon
      0.33 +-141%  +25000.0%      83.67 +- 81%  numa-vmstat.node3.nr_zone_inactive_file
     61799 +-  4%      -7.8%      56960        numa-vmstat.node3.nr_zone_unevictable
    217951 +-  8%    +280.8%     829976 +- 65%  numa-vmstat.node3.numa_hit
     91303 +- 19%    +689.3%     720647 +- 77%  numa-vmstat.node3.numa_local
    126648           -13.7%     109329 +- 13%  numa-vmstat.node3.numa_other
      8.54            -0.1        8.40        perf-profile.calltrace.cycles-pp.dequeue_task_fair.__schedule.schedule.pipe_wait.pipe_read
      5.04            -0.1        4.94        perf-profile.calltrace.cycles-pp.__switch_to.read
      3.43            -0.1        3.35        perf-profile.calltrace.cycles-pp.syscall_return_via_sysret.write
      2.77            -0.1        2.72        perf-profile.calltrace.cycles-pp.reweight_entity.enqueue_task_fair.ttwu_do_activate.try_to_wake_up.autoremove_wake_function
      1.99            -0.0        1.94        perf-profile.calltrace.cycles-pp.copy_page_to_iter.pipe_read.__vfs_read.vfs_read.ksys_read
      0.60 +-  2%      -0.0        0.57 +-  2%  perf-profile.calltrace.cycles-pp.find_next_bit.cpumask_next_wrap.select_idle_sibling.select_task_rq_fair.try_to_wake_up
      0.81            -0.0        0.78        perf-profile.calltrace.cycles-pp.___perf_sw_event.__schedule.schedule.pipe_wait.pipe_read
      0.78            +0.0        0.80        perf-profile.calltrace.cycles-pp.__fdget_pos.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe.write
      0.73            +0.0        0.75        perf-profile.calltrace.cycles-pp.__fget_light.__fdget_pos.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.92            +0.0        0.95        perf-profile.calltrace.cycles-pp.check_preempt_wakeup.check_preempt_curr.ttwu_do_wakeup.try_to_wake_up.autoremove_wake_function
      2.11            +0.0        2.15        perf-profile.calltrace.cycles-pp.security_file_permission.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      7.00            -0.1        6.86        perf-profile.children.cycles-pp.syscall_return_via_sysret
      5.26            -0.1        5.14        perf-profile.children.cycles-pp.__switch_to
      5.65            -0.1        5.56        perf-profile.children.cycles-pp.reweight_entity
      2.17            -0.1        2.12        perf-profile.children.cycles-pp.copy_page_to_iter
      2.94            -0.0        2.90        perf-profile.children.cycles-pp.update_cfs_group
      3.11            -0.0        3.07        perf-profile.children.cycles-pp.pick_next_task_fair
      2.59            -0.0        2.55        perf-profile.children.cycles-pp.load_new_mm_cr3
      1.92            -0.0        1.88        perf-profile.children.cycles-pp._raw_spin_lock_irqsave
      1.11            -0.0        1.08 +-  2%  perf-profile.children.cycles-pp.find_next_bit
      0.59            -0.0        0.56        perf-profile.children.cycles-pp.finish_task_switch
      0.14 +- 15%      -0.0        0.11 +- 16%  perf-profile.children.cycles-pp.write@plt
      1.21            -0.0        1.18        perf-profile.children.cycles-pp.set_next_entity
      0.85            -0.0        0.82        perf-profile.children.cycles-pp.___perf_sw_event
      0.13 +-  3%      -0.0        0.11 +-  4%  perf-profile.children.cycles-pp.timespec_trunc
      0.47 +-  2%      -0.0        0.45        perf-profile.children.cycles-pp.anon_pipe_buf_release
      0.38 +-  2%      -0.0        0.36        perf-profile.children.cycles-pp.file_update_time
      0.74            -0.0        0.73        perf-profile.children.cycles-pp.copyout
      0.41 +-  2%      -0.0        0.39        perf-profile.children.cycles-pp.copy_user_enhanced_fast_string
      0.32            -0.0        0.30        perf-profile.children.cycles-pp.__x64_sys_read
      0.14            -0.0        0.12 +-  3%  perf-profile.children.cycles-pp.current_kernel_time64
      0.91            +0.0        0.92        perf-profile.children.cycles-pp.touch_atime
      0.40            +0.0        0.41        perf-profile.children.cycles-pp._cond_resched
      0.18 +-  2%      +0.0        0.20        perf-profile.children.cycles-pp.activate_task
      0.05            +0.0        0.07 +-  6%  perf-profile.children.cycles-pp.default_wake_function
      0.24            +0.0        0.27 +-  3%  perf-profile.children.cycles-pp.rcu_all_qs
      0.60 +-  2%      +0.0        0.64 +-  2%  perf-profile.children.cycles-pp.update_min_vruntime
      0.42 +-  4%      +0.0        0.46 +-  4%  perf-profile.children.cycles-pp.probe_sched_switch
      1.33            +0.0        1.38        perf-profile.children.cycles-pp.__fget_light
      0.53 +-  2%      +0.1        0.58        perf-profile.children.cycles-pp.entry_SYSCALL_64_stage2
      0.31            +0.1        0.36 +-  2%  perf-profile.children.cycles-pp.generic_pipe_buf_confirm
      4.35            +0.1        4.41        perf-profile.children.cycles-pp.switch_mm_irqs_off
      2.52            +0.1        2.58        perf-profile.children.cycles-pp.selinux_file_permission
      0.00            +0.1        0.07 +- 11%  perf-profile.children.cycles-pp.hrtick_update
      7.00            -0.1        6.86        perf-profile.self.cycles-pp.syscall_return_via_sysret
      5.26            -0.1        5.14        perf-profile.self.cycles-pp.__switch_to
      0.29            -0.1        0.19 +-  2%  perf-profile.self.cycles-pp.ksys_read
      1.49            -0.1        1.43        perf-profile.self.cycles-pp.dequeue_task_fair
      2.41            -0.1        2.35        perf-profile.self.cycles-pp.__schedule
      1.46            -0.0        1.41        perf-profile.self.cycles-pp.select_task_rq_fair
      2.94            -0.0        2.90        perf-profile.self.cycles-pp.update_cfs_group
      0.44            -0.0        0.40        perf-profile.self.cycles-pp.dequeue_entity
      0.48            -0.0        0.44        perf-profile.self.cycles-pp.finish_task_switch
      2.59            -0.0        2.55        perf-profile.self.cycles-pp.load_new_mm_cr3
      1.11            -0.0        1.08 +-  2%  perf-profile.self.cycles-pp.find_next_bit
      1.91            -0.0        1.88        perf-profile.self.cycles-pp._raw_spin_lock_irqsave
      0.78            -0.0        0.75        perf-profile.self.cycles-pp.___perf_sw_event
      0.14 +- 15%      -0.0        0.11 +- 16%  perf-profile.self.cycles-pp.write@plt
      0.37            -0.0        0.35 +-  2%  perf-profile.self.cycles-pp.__wake_up_common_lock
      0.20 +-  2%      -0.0        0.17 +-  2%  perf-profile.self.cycles-pp.__fdget_pos
      0.47 +-  2%      -0.0        0.44        perf-profile.self.cycles-pp.anon_pipe_buf_release
      0.87            -0.0        0.85        perf-profile.self.cycles-pp.copy_user_generic_unrolled
      0.13 +-  3%      -0.0        0.11 +-  4%  perf-profile.self.cycles-pp.timespec_trunc
      0.41 +-  2%      -0.0        0.39        perf-profile.self.cycles-pp.copy_user_enhanced_fast_string
      0.38            -0.0        0.36        perf-profile.self.cycles-pp.__wake_up_common
      0.32            -0.0        0.30        perf-profile.self.cycles-pp.__x64_sys_read
      0.14 +-  3%      -0.0        0.12 +-  3%  perf-profile.self.cycles-pp.current_kernel_time64
      0.30            -0.0        0.28        perf-profile.self.cycles-pp.set_next_entity
      0.28 +-  3%      +0.0        0.30        perf-profile.self.cycles-pp._cond_resched
      0.18 +-  2%      +0.0        0.20        perf-profile.self.cycles-pp.activate_task
      0.17 +-  2%      +0.0        0.19        perf-profile.self.cycles-pp.__might_fault
      0.05            +0.0        0.07 +-  6%  perf-profile.self.cycles-pp.default_wake_function
      0.17 +-  2%      +0.0        0.20        perf-profile.self.cycles-pp.ttwu_do_activate
      0.66            +0.0        0.69        perf-profile.self.cycles-pp.write
      0.24            +0.0        0.27 +-  3%  perf-profile.self.cycles-pp.rcu_all_qs
      0.67            +0.0        0.70        perf-profile.self.cycles-pp.entry_SYSCALL_64_after_hwframe
      0.60 +-  2%      +0.0        0.64 +-  2%  perf-profile.self.cycles-pp.update_min_vruntime
      0.42 +-  4%      +0.0        0.46 +-  4%  perf-profile.self.cycles-pp.probe_sched_switch
      1.33            +0.0        1.37        perf-profile.self.cycles-pp.__fget_light
      1.61            +0.0        1.66        perf-profile.self.cycles-pp.pipe_read
      0.53 +-  2%      +0.1        0.58        perf-profile.self.cycles-pp.entry_SYSCALL_64_stage2
      0.31            +0.1        0.36 +-  2%  perf-profile.self.cycles-pp.generic_pipe_buf_confirm
      1.04            +0.1        1.11        perf-profile.self.cycles-pp.pipe_write
      0.00            +0.1        0.07 +- 11%  perf-profile.self.cycles-pp.hrtick_update
      2.00            +0.1        2.08        perf-profile.self.cycles-pp.switch_mm_irqs_off

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/never/page_fault3/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
          1:3          -33%            :3     dmesg.WARNING:stack_going_in_the_wrong_direction?ip=file_update_time/0x
           :3           33%           1:3     stderr.mount.nfs:Connection_timed_out
         34:3         -401%          22:3     perf-profile.calltrace.cycles-pp.error_entry.testcase
         17:3         -207%          11:3     perf-profile.calltrace.cycles-pp.sync_regs.error_entry.testcase
         34:3         -404%          22:3     perf-profile.children.cycles-pp.error_entry
          0:3           -2%           0:3     perf-profile.children.cycles-pp.error_exit
         16:3         -196%          11:3     perf-profile.self.cycles-pp.error_entry
          0:3           -2%           0:3     perf-profile.self.cycles-pp.error_exit
         %stddev     %change         %stddev
             \          |                \  
    467454            -1.8%     459251        will-it-scale.per_process_ops
     10856 +-  4%     -23.1%       8344 +-  7%  will-it-scale.per_thread_ops
    118134 +-  2%     +11.7%     131943        will-it-scale.time.involuntary_context_switches
 6.277e+08 +-  4%     -23.1%  4.827e+08 +-  7%  will-it-scale.time.minor_page_faults
      7406            +5.8%       7839        will-it-scale.time.percent_of_cpu_this_job_got
     44526            +5.8%      47106        will-it-scale.time.system_time
   7351468 +-  5%     -18.3%    6009014 +-  7%  will-it-scale.time.voluntary_context_switches
  91835846            -2.2%   89778599        will-it-scale.workload
   2534640            +4.3%    2643005 +-  2%  interrupts.CAL:Function_call_interrupts
      2819 +-  5%     +22.9%       3464 +- 18%  kthread_noise.total_time
     30273 +-  4%     -12.7%      26415 +-  5%  vmstat.system.cs
      1.52 +-  2%     +15.2%       1.75 +-  2%  irq_exception_noise.__do_page_fault.99th
    296.67 +- 12%     -36.7%     187.67 +- 12%  irq_exception_noise.softirq_time
    230900 +-  3%     +30.3%     300925 +-  3%  meminfo.Inactive
    230184 +-  3%     +30.4%     300180 +-  3%  meminfo.Inactive(anon)
     11.62 +-  3%      -2.2        9.40 +-  5%  mpstat.cpu.idle%
      0.00 +- 14%      -0.0        0.00 +-  4%  mpstat.cpu.iowait%
   7992174           -11.1%    7101976 +-  3%  softirqs.RCU
   4973624 +-  2%     -12.9%    4333370 +-  2%  softirqs.SCHED
    118134 +-  2%     +11.7%     131943        time.involuntary_context_switches
 6.277e+08 +-  4%     -23.1%  4.827e+08 +-  7%  time.minor_page_faults
      7406            +5.8%       7839        time.percent_of_cpu_this_job_got
     44526            +5.8%      47106        time.system_time
   7351468 +-  5%     -18.3%    6009014 +-  7%  time.voluntary_context_switches
 2.702e+09 +-  5%     -16.7%  2.251e+09 +-  7%  cpuidle.C1E.time
   6834329 +-  5%     -15.8%    5756243 +-  7%  cpuidle.C1E.usage
 1.046e+10 +-  3%     -19.8%  8.389e+09 +-  4%  cpuidle.C6.time
  13961845 +-  3%     -19.3%   11265555 +-  4%  cpuidle.C6.usage
   1309307 +-  7%     -14.8%    1116168 +-  8%  cpuidle.POLL.time
     19774 +-  6%     -13.7%      17063 +-  7%  cpuidle.POLL.usage
      2523 +-  4%     -11.1%       2243 +-  4%  slabinfo.biovec-64.active_objs
      2523 +-  4%     -11.1%       2243 +-  4%  slabinfo.biovec-64.num_objs
      2610 +-  8%     -33.7%       1731 +- 22%  slabinfo.dmaengine-unmap-16.active_objs
      2610 +-  8%     -33.7%       1731 +- 22%  slabinfo.dmaengine-unmap-16.num_objs
      5118 +- 17%     -22.6%       3962 +-  9%  slabinfo.eventpoll_pwq.active_objs
      5118 +- 17%     -22.6%       3962 +-  9%  slabinfo.eventpoll_pwq.num_objs
      4583 +-  3%     -14.0%       3941 +-  4%  slabinfo.sock_inode_cache.active_objs
      4583 +-  3%     -14.0%       3941 +-  4%  slabinfo.sock_inode_cache.num_objs
      1933            +2.6%       1984        turbostat.Avg_MHz
   6832021 +-  5%     -15.8%    5754156 +-  7%  turbostat.C1E
      2.32 +-  5%      -0.4        1.94 +-  7%  turbostat.C1E%
  13954211 +-  3%     -19.3%   11259436 +-  4%  turbostat.C6
      8.97 +-  3%      -1.8        7.20 +-  4%  turbostat.C6%
      6.18 +-  4%     -17.1%       5.13 +-  5%  turbostat.CPU%c1
      5.12 +-  3%     -21.7%       4.01 +-  4%  turbostat.CPU%c6
      1.76 +-  2%     -34.7%       1.15 +-  2%  turbostat.Pkg%pc2
     57314 +-  4%     +30.4%      74717 +-  4%  proc-vmstat.nr_inactive_anon
     57319 +-  4%     +30.4%      74719 +-  4%  proc-vmstat.nr_zone_inactive_anon
     24415 +- 19%     -62.2%       9236 +-  7%  proc-vmstat.numa_hint_faults
  69661453            -1.8%   68405712        proc-vmstat.numa_hit
  69553390            -1.8%   68297790        proc-vmstat.numa_local
      8792 +- 29%     -92.6%     654.33 +- 23%  proc-vmstat.numa_pages_migrated
     40251 +- 32%     -76.5%       9474 +-  3%  proc-vmstat.numa_pte_updates
  69522532            -1.6%   68383074        proc-vmstat.pgalloc_normal
 2.762e+10            -2.2%  2.701e+10        proc-vmstat.pgfault
  68825100            -1.5%   67772256        proc-vmstat.pgfree
      8792 +- 29%     -92.6%     654.33 +- 23%  proc-vmstat.pgmigrate_success
     57992 +-  6%     +56.2%      90591 +-  3%  numa-meminfo.node0.Inactive
     57916 +-  6%     +56.3%      90513 +-  3%  numa-meminfo.node0.Inactive(anon)
     37285 +- 12%     +36.0%      50709 +-  5%  numa-meminfo.node0.SReclaimable
    110971 +-  8%     +22.7%     136209 +-  8%  numa-meminfo.node0.Slab
     23601 +- 55%    +559.5%     155651 +- 36%  numa-meminfo.node1.AnonPages
     62484 +- 12%     +17.5%      73417 +-  3%  numa-meminfo.node1.Inactive
     62323 +- 12%     +17.2%      73023 +-  4%  numa-meminfo.node1.Inactive(anon)
    109714 +- 63%     -85.6%      15832 +- 96%  numa-meminfo.node2.AnonPages
     52236 +- 13%     +22.7%      64074 +-  3%  numa-meminfo.node2.Inactive
     51922 +- 12%     +23.2%      63963 +-  3%  numa-meminfo.node2.Inactive(anon)
     60241 +- 11%     +21.9%      73442 +-  8%  numa-meminfo.node3.Inactive
     60077 +- 12%     +22.0%      73279 +-  8%  numa-meminfo.node3.Inactive(anon)
     14093 +-  6%     +55.9%      21977 +-  3%  numa-vmstat.node0.nr_inactive_anon
      9321 +- 12%     +36.0%      12675 +-  5%  numa-vmstat.node0.nr_slab_reclaimable
     14090 +-  6%     +56.0%      21977 +-  3%  numa-vmstat.node0.nr_zone_inactive_anon
      5900 +- 55%    +559.4%      38909 +- 36%  numa-vmstat.node1.nr_anon_pages
     15413 +- 12%     +14.8%      17688 +-  4%  numa-vmstat.node1.nr_inactive_anon
     15413 +- 12%     +14.8%      17688 +-  4%  numa-vmstat.node1.nr_zone_inactive_anon
     27430 +- 63%     -85.6%       3960 +- 96%  numa-vmstat.node2.nr_anon_pages
     12928 +- 12%     +20.0%      15508 +-  3%  numa-vmstat.node2.nr_inactive_anon
     12927 +- 12%     +20.0%      15507 +-  3%  numa-vmstat.node2.nr_zone_inactive_anon
      6229 +- 10%    +117.5%      13547 +- 44%  numa-vmstat.node3
     14669 +- 11%     +19.6%      17537 +-  7%  numa-vmstat.node3.nr_inactive_anon
     14674 +- 11%     +19.5%      17541 +-  7%  numa-vmstat.node3.nr_zone_inactive_anon
     24617 +-141%    -100.0%       0.00        latency_stats.avg.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      5049 +-105%     -99.4%      28.33 +- 82%  latency_stats.avg.call_rwsem_down_write_failed.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
    152457 +- 27%    +233.6%     508656 +- 92%  latency_stats.avg.max
      0.00       +3.9e+107%     390767 +-141%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_openat
     24617 +-141%    -100.0%       0.00        latency_stats.max.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4240 +-141%    -100.0%       0.00        latency_stats.max.call_rwsem_down_write_failed.do_unlinkat.do_syscall_64.entry_SYSCALL_64_after_hwframe
      8565 +- 70%     -99.1%      80.33 +-115%  latency_stats.max.call_rwsem_down_write_failed.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
    204835 +-  6%    +457.6%    1142244 +-114%  latency_stats.max.max
      0.00       +5.1e+105%       5057 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_openat.do_filp_open
      0.00         +1e+108%     995083 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_openat
     13175 +-  4%    -100.0%       0.00        latency_stats.sum.io_schedule.__lock_page_or_retry.filemap_fault.__do_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault.page_fault
     24617 +-141%    -100.0%       0.00        latency_stats.sum.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4260 +-141%    -100.0%       0.00        latency_stats.sum.call_rwsem_down_write_failed.do_unlinkat.do_syscall_64.entry_SYSCALL_64_after_hwframe
      8640 +- 70%     -97.5%     216.33 +-108%  latency_stats.sum.call_rwsem_down_write_failed.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      6673 +- 89%     -92.8%     477.67 +- 74%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
      0.00       +4.2e+105%       4228 +-130%  latency_stats.sum.io_schedule.__lock_page_killable.__lock_page_or_retry.filemap_fault.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault.page_fault
      0.00       +7.5e+105%       7450 +- 98%  latency_stats.sum.io_schedule.__lock_page_or_retry.filemap_fault.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault.page_fault
      0.00       +1.3e+106%      13050 +-141%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_openat.do_filp_open
      0.00       +1.5e+110%  1.508e+08 +-141%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_openat
      0.97            -0.0        0.94        perf-stat.branch-miss-rate%
 1.329e+11            -2.6%  1.294e+11        perf-stat.branch-misses
 2.254e+11            -1.9%   2.21e+11        perf-stat.cache-references
  18308779 +-  4%     -12.8%   15969618 +-  5%  perf-stat.context-switches
      3.20            +1.8%       3.26        perf-stat.cpi
 2.233e+14            +2.7%  2.293e+14        perf-stat.cpu-cycles
      4.01            -0.2        3.83        perf-stat.dTLB-store-miss-rate%
  4.51e+11            -2.2%   4.41e+11        perf-stat.dTLB-store-misses
  1.08e+13            +2.6%  1.109e+13        perf-stat.dTLB-stores
 3.158e+10 +-  5%     +16.8%  3.689e+10 +-  2%  perf-stat.iTLB-load-misses
      2214 +-  5%     -13.8%       1907 +-  2%  perf-stat.instructions-per-iTLB-miss
      0.31            -1.8%       0.31        perf-stat.ipc
 2.762e+10            -2.2%  2.701e+10        perf-stat.minor-faults
 1.535e+10           -11.2%  1.362e+10        perf-stat.node-loads
      9.75            +1.1       10.89        perf-stat.node-store-miss-rate%
 3.012e+09           +10.6%  3.332e+09 +-  2%  perf-stat.node-store-misses
 2.787e+10            -2.2%  2.725e+10        perf-stat.node-stores
 2.762e+10            -2.2%  2.701e+10        perf-stat.page-faults
    759458            +3.2%     783404        perf-stat.path-length
    246.39 +- 15%     -20.4%     196.12 +-  6%  sched_debug.cfs_rq:/.load_avg.max
      0.21 +-  3%      +9.0%       0.23 +-  4%  sched_debug.cfs_rq:/.nr_running.stddev
     16.64 +- 27%     +61.0%      26.79 +- 17%  sched_debug.cfs_rq:/.nr_spread_over.max
     75.15           -14.4%      64.30 +-  4%  sched_debug.cfs_rq:/.util_avg.stddev
    178.80 +-  3%     +25.4%     224.12 +-  7%  sched_debug.cfs_rq:/.util_est_enqueued.avg
      1075 +-  5%     -12.3%     943.36 +-  2%  sched_debug.cfs_rq:/.util_est_enqueued.max
   2093630 +- 27%     -36.1%    1337941 +- 16%  sched_debug.cpu.avg_idle.max
    297057 +- 11%     +37.8%     409294 +- 14%  sched_debug.cpu.avg_idle.min
    293240 +- 55%     -62.3%     110571 +- 13%  sched_debug.cpu.avg_idle.stddev
    770075 +-  9%     -19.3%     621136 +- 12%  sched_debug.cpu.max_idle_balance_cost.max
     48919 +- 46%     -66.9%      16190 +- 81%  sched_debug.cpu.max_idle_balance_cost.stddev
     21716 +-  5%     -16.8%      18061 +-  7%  sched_debug.cpu.nr_switches.min
     21519 +-  5%     -17.7%      17700 +-  7%  sched_debug.cpu.sched_count.min
     10586 +-  5%     -18.1%       8669 +-  7%  sched_debug.cpu.sched_goidle.avg
     14183 +-  3%     -17.6%      11693 +-  5%  sched_debug.cpu.sched_goidle.max
     10322 +-  5%     -18.6%       8407 +-  7%  sched_debug.cpu.sched_goidle.min
    400.99 +-  8%     -13.0%     348.75 +-  3%  sched_debug.cpu.sched_goidle.stddev
      5459 +-  8%     +10.0%       6006 +-  3%  sched_debug.cpu.ttwu_local.avg
      8.47 +- 42%    +345.8%      37.73 +- 77%  sched_debug.rt_rq:/.rt_time.max
      0.61 +- 42%    +343.0%       2.72 +- 77%  sched_debug.rt_rq:/.rt_time.stddev
     91.98           -30.9       61.11 +- 70%  perf-profile.calltrace.cycles-pp.testcase
      9.05            -9.1        0.00        perf-profile.calltrace.cycles-pp.__do_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      8.91            -8.9        0.00        perf-profile.calltrace.cycles-pp.shmem_fault.__do_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      8.06            -8.1        0.00        perf-profile.calltrace.cycles-pp.shmem_getpage_gfp.shmem_fault.__do_fault.__handle_mm_fault.handle_mm_fault
      7.59            -7.6        0.00        perf-profile.calltrace.cycles-pp.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault.__handle_mm_fault
      7.44            -7.4        0.00        perf-profile.calltrace.cycles-pp.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      7.28            -7.3        0.00        perf-profile.calltrace.cycles-pp.alloc_set_pte.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      5.31            -5.3        0.00        perf-profile.calltrace.cycles-pp.page_add_file_rmap.alloc_set_pte.finish_fault.__handle_mm_fault.handle_mm_fault
      8.08            -2.8        5.30 +- 70%  perf-profile.calltrace.cycles-pp.native_irq_return_iret.testcase
      5.95            -2.1        3.83 +- 70%  perf-profile.calltrace.cycles-pp.find_get_entry.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault
      5.95            -2.0        3.93 +- 70%  perf-profile.calltrace.cycles-pp.swapgs_restore_regs_and_return_to_usermode.testcase
      3.10            -1.1        2.01 +- 70%  perf-profile.calltrace.cycles-pp.__perf_sw_event.__do_page_fault.do_page_fault.page_fault.testcase
      2.36            -0.8        1.55 +- 70%  perf-profile.calltrace.cycles-pp.___perf_sw_event.__perf_sw_event.__do_page_fault.do_page_fault.page_fault
      1.08            -0.4        0.70 +- 70%  perf-profile.calltrace.cycles-pp.do_page_fault.testcase
      0.82            -0.3        0.54 +- 70%  perf-profile.calltrace.cycles-pp.trace_graph_entry.do_page_fault.testcase
      0.77            -0.3        0.50 +- 70%  perf-profile.calltrace.cycles-pp.ftrace_graph_caller.__do_page_fault.do_page_fault.page_fault.testcase
      0.59            -0.2        0.37 +- 70%  perf-profile.calltrace.cycles-pp.down_read_trylock.__do_page_fault.do_page_fault.page_fault.testcase
     91.98           -30.9       61.11 +- 70%  perf-profile.children.cycles-pp.testcase
      9.14            -3.2        5.99 +- 70%  perf-profile.children.cycles-pp.__do_fault
      8.20            -2.8        5.40 +- 70%  perf-profile.children.cycles-pp.shmem_getpage_gfp
      8.08            -2.8        5.31 +- 70%  perf-profile.children.cycles-pp.native_irq_return_iret
      6.08            -2.2        3.92 +- 70%  perf-profile.children.cycles-pp.find_get_entry
      6.08            -2.1        3.96 +- 70%  perf-profile.children.cycles-pp.sync_regs
      5.95            -2.0        3.93 +- 70%  perf-profile.children.cycles-pp.swapgs_restore_regs_and_return_to_usermode
      4.12            -1.4        2.73 +- 70%  perf-profile.children.cycles-pp.ftrace_graph_caller
      3.65            -1.2        2.42 +- 70%  perf-profile.children.cycles-pp.prepare_ftrace_return
      3.18            -1.1        2.07 +- 70%  perf-profile.children.cycles-pp.__perf_sw_event
      2.34            -0.8        1.52 +- 70%  perf-profile.children.cycles-pp.fault_dirty_shared_page
      0.80            -0.3        0.50 +- 70%  perf-profile.children.cycles-pp._raw_spin_lock
      0.76            -0.3        0.50 +- 70%  perf-profile.children.cycles-pp.tlb_flush_mmu_free
      0.61            -0.2        0.39 +- 70%  perf-profile.children.cycles-pp.down_read_trylock
      0.48 +-  2%      -0.2        0.28 +- 70%  perf-profile.children.cycles-pp.pmd_devmap_trans_unstable
      0.26 +-  6%      -0.1        0.15 +- 71%  perf-profile.children.cycles-pp.ktime_get
      0.20 +-  2%      -0.1        0.12 +- 70%  perf-profile.children.cycles-pp.perf_exclude_event
      0.22 +-  2%      -0.1        0.13 +- 70%  perf-profile.children.cycles-pp._cond_resched
      0.17            -0.1        0.11 +- 70%  perf-profile.children.cycles-pp.page_rmapping
      0.13            -0.1        0.07 +- 70%  perf-profile.children.cycles-pp.rcu_all_qs
      0.07            -0.0        0.04 +- 70%  perf-profile.children.cycles-pp.ftrace_lookup_ip
     22.36            -7.8       14.59 +- 70%  perf-profile.self.cycles-pp.testcase
      8.08            -2.8        5.31 +- 70%  perf-profile.self.cycles-pp.native_irq_return_iret
      6.08            -2.1        3.96 +- 70%  perf-profile.self.cycles-pp.sync_regs
      5.81            -2.0        3.84 +- 70%  perf-profile.self.cycles-pp.swapgs_restore_regs_and_return_to_usermode
      3.27            -1.6        1.65 +- 70%  perf-profile.self.cycles-pp.__handle_mm_fault
      3.79            -1.4        2.36 +- 70%  perf-profile.self.cycles-pp.find_get_entry
      3.80            -1.3        2.53 +- 70%  perf-profile.self.cycles-pp.trace_graph_entry
      1.10            -0.5        0.57 +- 70%  perf-profile.self.cycles-pp.alloc_set_pte
      1.24            -0.4        0.81 +- 70%  perf-profile.self.cycles-pp.shmem_fault
      0.80            -0.3        0.50 +- 70%  perf-profile.self.cycles-pp._raw_spin_lock
      0.81            -0.3        0.51 +- 70%  perf-profile.self.cycles-pp.find_lock_entry
      0.80 +-  2%      -0.3        0.51 +- 70%  perf-profile.self.cycles-pp.__perf_sw_event
      0.61            -0.2        0.38 +- 70%  perf-profile.self.cycles-pp.down_read_trylock
      0.60            -0.2        0.39 +- 70%  perf-profile.self.cycles-pp.shmem_getpage_gfp
      0.48            -0.2        0.27 +- 70%  perf-profile.self.cycles-pp.pmd_devmap_trans_unstable
      0.47            -0.2        0.30 +- 70%  perf-profile.self.cycles-pp.file_update_time
      0.34            -0.1        0.22 +- 70%  perf-profile.self.cycles-pp.do_page_fault
      0.22 +-  4%      -0.1        0.11 +- 70%  perf-profile.self.cycles-pp.__do_fault
      0.25 +-  5%      -0.1        0.14 +- 71%  perf-profile.self.cycles-pp.ktime_get
      0.21 +-  2%      -0.1        0.12 +- 70%  perf-profile.self.cycles-pp.finish_fault
      0.23 +-  2%      -0.1        0.14 +- 70%  perf-profile.self.cycles-pp.fault_dirty_shared_page
      0.22 +-  2%      -0.1        0.14 +- 70%  perf-profile.self.cycles-pp.prepare_exit_to_usermode
      0.20 +-  2%      -0.1        0.12 +- 70%  perf-profile.self.cycles-pp.perf_exclude_event
      0.16            -0.1        0.10 +- 70%  perf-profile.self.cycles-pp._cond_resched
      0.13            -0.1        0.07 +- 70%  perf-profile.self.cycles-pp.rcu_all_qs
      0.07            -0.0        0.04 +- 70%  perf-profile.self.cycles-pp.ftrace_lookup_ip

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/always/context_switch1/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :3           33%           1:3     dmesg.WARNING:at#for_ip_interrupt_entry/0x
           :3           33%           1:3     dmesg.WARNING:at#for_ip_ret_from_intr/0x
           :3           67%           2:3     kmsg.pstore:crypto_comp_decompress_failed,ret=
           :3           67%           2:3     kmsg.pstore:decompression_failed
         %stddev     %change         %stddev
             \          |                \  
    223910            -1.3%     220930        will-it-scale.per_process_ops
    233722            -1.0%     231288        will-it-scale.per_thread_ops
 6.001e+08 +- 13%     +31.4%  7.887e+08 +-  4%  will-it-scale.time.involuntary_context_switches
     18003 +-  4%     +10.9%      19956        will-it-scale.time.minor_page_faults
  1.29e+10            -2.5%  1.258e+10        will-it-scale.time.voluntary_context_switches
  87865617            -1.2%   86826277        will-it-scale.workload
   2880329 +-  2%      +5.4%    3034904        interrupts.CAL:Function_call_interrupts
   7695018           -23.3%    5905066 +-  8%  meminfo.DirectMap2M
      0.00 +- 39%      -0.0        0.00 +- 78%  mpstat.cpu.iowait%
      4621 +- 12%     +13.4%       5241        proc-vmstat.numa_hint_faults_local
    715714           +27.6%     913142 +- 13%  softirqs.SCHED
    515653 +-  6%     -20.0%     412650 +- 15%  turbostat.C1
  43643516            -1.2%   43127031        vmstat.system.cs
   2893393 +-  4%     -23.6%    2210524 +- 10%  cpuidle.C1.time
    518051 +-  6%     -19.9%     415081 +- 15%  cpuidle.C1.usage
     23.10           +22.9%      28.38 +-  9%  boot-time.boot
     18.38           +23.2%      22.64 +- 12%  boot-time.dhcp
      5216            +5.0%       5478 +-  2%  boot-time.idle
    963.76 +- 44%    +109.7%       2021 +- 34%  irq_exception_noise.__do_page_fault.sum
      6.33 +- 14%    +726.3%      52.33 +- 62%  irq_exception_noise.irq_time
     56524 +-  7%     -18.8%      45915 +-  4%  irq_exception_noise.softirq_time
 6.001e+08 +- 13%     +31.4%  7.887e+08 +-  4%  time.involuntary_context_switches
     18003 +-  4%     +10.9%      19956        time.minor_page_faults
  1.29e+10            -2.5%  1.258e+10        time.voluntary_context_switches
      1386 +-  7%     +15.4%       1600 +- 11%  slabinfo.scsi_sense_cache.active_objs
      1386 +-  7%     +15.4%       1600 +- 11%  slabinfo.scsi_sense_cache.num_objs
      1427 +-  5%      -8.9%       1299 +-  2%  slabinfo.task_group.active_objs
      1427 +-  5%      -8.9%       1299 +-  2%  slabinfo.task_group.num_objs
     65519 +- 12%     +20.6%      79014 +- 16%  numa-meminfo.node0.SUnreclaim
      8484           -11.9%       7475 +-  7%  numa-meminfo.node1.KernelStack
      9264 +- 26%     -33.7%       6146 +-  7%  numa-meminfo.node1.Mapped
      2138 +- 61%    +373.5%      10127 +- 92%  numa-meminfo.node3.Inactive
      2059 +- 61%    +387.8%      10046 +- 93%  numa-meminfo.node3.Inactive(anon)
     16379 +- 12%     +20.6%      19752 +- 16%  numa-vmstat.node0.nr_slab_unreclaimable
      8483           -11.9%       7474 +-  7%  numa-vmstat.node1.nr_kernel_stack
      6250 +- 29%     -42.8%       3575 +- 24%  numa-vmstat.node2
      3798 +- 17%     +63.7%       6218 +-  5%  numa-vmstat.node3
    543.00 +- 61%    +368.1%       2541 +- 91%  numa-vmstat.node3.nr_inactive_anon
    543.33 +- 61%    +367.8%       2541 +- 91%  numa-vmstat.node3.nr_zone_inactive_anon
 4.138e+13            -1.1%   4.09e+13        perf-stat.branch-instructions
 6.569e+11            -2.0%  6.441e+11        perf-stat.branch-misses
 2.645e+10            -1.2%  2.613e+10        perf-stat.context-switches
      1.21            +1.2%       1.23        perf-stat.cpi
    153343 +-  2%     -12.1%     134776        perf-stat.cpu-migrations
 5.966e+13            -1.3%  5.889e+13        perf-stat.dTLB-loads
 3.736e+13            -1.2%   3.69e+13        perf-stat.dTLB-stores
      5.85 +- 15%      +8.8       14.67 +-  9%  perf-stat.iTLB-load-miss-rate%
 3.736e+09 +- 17%    +161.3%   9.76e+09 +- 11%  perf-stat.iTLB-load-misses
 5.987e+10            -5.4%  5.667e+10        perf-stat.iTLB-loads
 2.079e+14            -1.2%  2.054e+14        perf-stat.instructions
     57547 +- 18%     -62.9%      21340 +- 11%  perf-stat.instructions-per-iTLB-miss
      0.82            -1.2%       0.81        perf-stat.ipc
  27502531 +-  8%      +9.5%   30122136 +-  3%  perf-stat.node-store-misses
      1449 +- 27%     -34.6%     948.85        sched_debug.cfs_rq:/.load.min
    319416 +-115%    -188.5%    -282549        sched_debug.cfs_rq:/.spread0.avg
    657044 +- 55%     -88.3%      76887 +- 23%  sched_debug.cfs_rq:/.spread0.max
  -1525243           +54.6%   -2357898        sched_debug.cfs_rq:/.spread0.min
    101614 +-  6%     +30.6%     132713 +- 19%  sched_debug.cpu.avg_idle.stddev
     11.54 +- 41%     -61.2%       4.48        sched_debug.cpu.cpu_load[1].avg
      1369 +- 67%     -98.5%      20.67 +- 48%  sched_debug.cpu.cpu_load[1].max
     99.29 +- 67%     -97.6%       2.35 +- 26%  sched_debug.cpu.cpu_load[1].stddev
      9.58 +- 38%     -55.2%       4.29        sched_debug.cpu.cpu_load[2].avg
      1024 +- 68%     -98.5%      15.27 +- 36%  sched_debug.cpu.cpu_load[2].max
     74.51 +- 67%     -97.3%       1.99 +- 15%  sched_debug.cpu.cpu_load[2].stddev
      7.37 +- 29%     -42.0%       4.28        sched_debug.cpu.cpu_load[3].avg
    600.58 +- 68%     -97.9%      12.48 +- 20%  sched_debug.cpu.cpu_load[3].max
     43.98 +- 66%     -95.8%       1.83 +-  5%  sched_debug.cpu.cpu_load[3].stddev
      5.95 +- 19%     -28.1%       4.28        sched_debug.cpu.cpu_load[4].avg
    325.39 +- 67%     -96.4%      11.67 +- 10%  sched_debug.cpu.cpu_load[4].max
     24.19 +- 65%     -92.5%       1.81 +-  3%  sched_debug.cpu.cpu_load[4].stddev
    907.23 +-  4%     -14.1%     779.70 +- 10%  sched_debug.cpu.nr_load_updates.stddev
      0.00 +- 83%    +122.5%       0.00        sched_debug.rt_rq:/.rt_time.min
      8.49 +-  2%      -0.3        8.21 +-  2%  perf-profile.calltrace.cycles-pp.dequeue_task_fair.__schedule.schedule.pipe_wait.pipe_read
     57.28            -0.3       57.01        perf-profile.calltrace.cycles-pp.read
      5.06            -0.2        4.85        perf-profile.calltrace.cycles-pp.select_task_rq_fair.try_to_wake_up.autoremove_wake_function.__wake_up_common.__wake_up_common_lock
      4.98            -0.2        4.78        perf-profile.calltrace.cycles-pp.__switch_to.read
      3.55            -0.2        3.39 +-  2%  perf-profile.calltrace.cycles-pp.syscall_return_via_sysret.read
      2.72            -0.1        2.60        perf-profile.calltrace.cycles-pp.reweight_entity.enqueue_task_fair.ttwu_do_activate.try_to_wake_up.autoremove_wake_function
      2.67            -0.1        2.57 +-  2%  perf-profile.calltrace.cycles-pp.reweight_entity.dequeue_task_fair.__schedule.schedule.pipe_wait
      3.40            -0.1        3.31        perf-profile.calltrace.cycles-pp.syscall_return_via_sysret.write
      3.77            -0.1        3.68        perf-profile.calltrace.cycles-pp.select_idle_sibling.select_task_rq_fair.try_to_wake_up.autoremove_wake_function.__wake_up_common
      1.95            -0.1        1.88        perf-profile.calltrace.cycles-pp.copy_page_to_iter.pipe_read.__vfs_read.vfs_read.ksys_read
      2.19            -0.1        2.13        perf-profile.calltrace.cycles-pp.__switch_to_asm.read
      1.30            -0.1        1.25        perf-profile.calltrace.cycles-pp.update_curr.reweight_entity.enqueue_task_fair.ttwu_do_activate.try_to_wake_up
      1.27            -0.1        1.22 +-  2%  perf-profile.calltrace.cycles-pp.update_curr.reweight_entity.dequeue_task_fair.__schedule.schedule
      2.29            -0.0        2.24        perf-profile.calltrace.cycles-pp.load_new_mm_cr3.switch_mm_irqs_off.__schedule.schedule.pipe_wait
      0.96            -0.0        0.92        perf-profile.calltrace.cycles-pp.__calc_delta.update_curr.reweight_entity.dequeue_task_fair.__schedule
      0.85            -0.0        0.81 +-  3%  perf-profile.calltrace.cycles-pp.cpumask_next_wrap.select_idle_sibling.select_task_rq_fair.try_to_wake_up.autoremove_wake_function
      1.63            -0.0        1.59        perf-profile.calltrace.cycles-pp.native_write_msr.read
      0.72            -0.0        0.69        perf-profile.calltrace.cycles-pp.copyout.copy_page_to_iter.pipe_read.__vfs_read.vfs_read
      0.65 +-  2%      -0.0        0.62        perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.try_to_wake_up.autoremove_wake_function.__wake_up_common.__wake_up_common_lock
      0.61            -0.0        0.58 +-  2%  perf-profile.calltrace.cycles-pp.find_next_bit.cpumask_next_wrap.select_idle_sibling.select_task_rq_fair.try_to_wake_up
      0.88            -0.0        0.85        perf-profile.calltrace.cycles-pp.touch_atime.pipe_read.__vfs_read.vfs_read.ksys_read
      0.80            -0.0        0.77 +-  2%  perf-profile.calltrace.cycles-pp.___perf_sw_event.__schedule.schedule.pipe_wait.pipe_read
      0.82            -0.0        0.79        perf-profile.calltrace.cycles-pp.prepare_to_wait.pipe_wait.pipe_read.__vfs_read.vfs_read
      0.72            -0.0        0.70        perf-profile.calltrace.cycles-pp.mutex_lock.pipe_write.__vfs_write.vfs_write.ksys_write
      0.56 +-  2%      -0.0        0.53        perf-profile.calltrace.cycles-pp.update_rq_clock.try_to_wake_up.autoremove_wake_function.__wake_up_common.__wake_up_common_lock
      0.83            -0.0        0.81        perf-profile.calltrace.cycles-pp.__wake_up_common_lock.pipe_read.__vfs_read.vfs_read.ksys_read
     42.40            +0.3       42.69        perf-profile.calltrace.cycles-pp.write
     31.80            +0.4       32.18        perf-profile.calltrace.cycles-pp.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
     24.35            +0.5       24.84        perf-profile.calltrace.cycles-pp.pipe_wait.pipe_read.__vfs_read.vfs_read.ksys_read
     20.36            +0.6       20.92 +-  2%  perf-profile.calltrace.cycles-pp.try_to_wake_up.autoremove_wake_function.__wake_up_common.__wake_up_common_lock.pipe_write
     22.01            +0.6       22.58        perf-profile.calltrace.cycles-pp.schedule.pipe_wait.pipe_read.__vfs_read.vfs_read
     21.87            +0.6       22.46        perf-profile.calltrace.cycles-pp.__schedule.schedule.pipe_wait.pipe_read.__vfs_read
      3.15 +- 11%      +1.0        4.12 +- 14%  perf-profile.calltrace.cycles-pp.ttwu_do_wakeup.try_to_wake_up.autoremove_wake_function.__wake_up_common.__wake_up_common_lock
      1.07 +- 34%      +1.1        2.12 +- 31%  perf-profile.calltrace.cycles-pp.tracing_record_taskinfo_sched_switch.__schedule.schedule.pipe_wait.pipe_read
      0.66 +- 75%      +1.1        1.72 +- 37%  perf-profile.calltrace.cycles-pp.trace_save_cmdline.tracing_record_taskinfo.ttwu_do_wakeup.try_to_wake_up.autoremove_wake_function
      0.75 +- 74%      +1.1        1.88 +- 34%  perf-profile.calltrace.cycles-pp.tracing_record_taskinfo.ttwu_do_wakeup.try_to_wake_up.autoremove_wake_function.__wake_up_common
      0.69 +- 76%      +1.2        1.85 +- 36%  perf-profile.calltrace.cycles-pp.trace_save_cmdline.tracing_record_taskinfo_sched_switch.__schedule.schedule.pipe_wait
      8.73 +-  2%      -0.3        8.45        perf-profile.children.cycles-pp.dequeue_task_fair
     57.28            -0.3       57.01        perf-profile.children.cycles-pp.read
      6.95            -0.2        6.70        perf-profile.children.cycles-pp.syscall_return_via_sysret
      5.57            -0.2        5.35        perf-profile.children.cycles-pp.reweight_entity
      5.26            -0.2        5.05        perf-profile.children.cycles-pp.select_task_rq_fair
      5.19            -0.2        4.99        perf-profile.children.cycles-pp.__switch_to
      4.90            -0.2        4.73 +-  2%  perf-profile.children.cycles-pp.update_curr
      1.27            -0.1        1.13 +-  8%  perf-profile.children.cycles-pp.fsnotify
      3.92            -0.1        3.83        perf-profile.children.cycles-pp.select_idle_sibling
      2.01            -0.1        1.93        perf-profile.children.cycles-pp.__calc_delta
      2.14            -0.1        2.06        perf-profile.children.cycles-pp.copy_page_to_iter
      1.58            -0.1        1.51        perf-profile.children.cycles-pp._raw_spin_unlock_irqrestore
      2.90            -0.1        2.84        perf-profile.children.cycles-pp.update_cfs_group
      1.93            -0.1        1.87        perf-profile.children.cycles-pp._raw_spin_lock_irqsave
      2.35            -0.1        2.29        perf-profile.children.cycles-pp.__switch_to_asm
      1.33            -0.1        1.27 +-  3%  perf-profile.children.cycles-pp.cpumask_next_wrap
      2.57            -0.1        2.52        perf-profile.children.cycles-pp.load_new_mm_cr3
      1.53            -0.1        1.47 +-  2%  perf-profile.children.cycles-pp.__fdget_pos
      1.11            -0.0        1.07 +-  2%  perf-profile.children.cycles-pp.find_next_bit
      1.18            -0.0        1.14        perf-profile.children.cycles-pp.update_rq_clock
      0.88            -0.0        0.83        perf-profile.children.cycles-pp.copy_user_generic_unrolled
      1.70            -0.0        1.65        perf-profile.children.cycles-pp.native_write_msr
      0.97            -0.0        0.93 +-  2%  perf-profile.children.cycles-pp.account_entity_dequeue
      0.59            -0.0        0.56        perf-profile.children.cycles-pp.finish_task_switch
      0.91            -0.0        0.88        perf-profile.children.cycles-pp.touch_atime
      0.69            -0.0        0.65        perf-profile.children.cycles-pp.account_entity_enqueue
      2.13            -0.0        2.09        perf-profile.children.cycles-pp.mutex_lock
      0.32 +-  3%      -0.0        0.29 +-  4%  perf-profile.children.cycles-pp.__sb_start_write
      0.84            -0.0        0.81 +-  2%  perf-profile.children.cycles-pp.___perf_sw_event
      0.89            -0.0        0.87        perf-profile.children.cycles-pp.prepare_to_wait
      0.73            -0.0        0.71        perf-profile.children.cycles-pp.copyout
      0.31 +-  2%      -0.0        0.28 +-  3%  perf-profile.children.cycles-pp.__list_del_entry_valid
      0.46 +-  2%      -0.0        0.44        perf-profile.children.cycles-pp.anon_pipe_buf_release
      0.38            -0.0        0.36 +-  3%  perf-profile.children.cycles-pp.idle_cpu
      0.32            -0.0        0.30 +-  2%  perf-profile.children.cycles-pp.__x64_sys_read
      0.21 +-  2%      -0.0        0.20 +-  2%  perf-profile.children.cycles-pp.deactivate_task
      0.13            -0.0        0.12 +-  4%  perf-profile.children.cycles-pp.timespec_trunc
      0.09            -0.0        0.08        perf-profile.children.cycles-pp.iov_iter_init
      0.08            -0.0        0.07        perf-profile.children.cycles-pp.native_load_tls
      0.11 +-  4%      +0.0        0.12        perf-profile.children.cycles-pp.tick_sched_timer
      0.08 +-  5%      +0.0        0.10 +-  4%  perf-profile.children.cycles-pp.finish_wait
      0.38 +-  2%      +0.0        0.40 +-  2%  perf-profile.children.cycles-pp.file_update_time
      0.31            +0.0        0.33 +-  2%  perf-profile.children.cycles-pp.smp_apic_timer_interrupt
      0.24 +-  3%      +0.0        0.26 +-  3%  perf-profile.children.cycles-pp.rcu_all_qs
      0.39            +0.0        0.41        perf-profile.children.cycles-pp._cond_resched
      0.05            +0.0        0.07 +-  6%  perf-profile.children.cycles-pp.default_wake_function
      0.23 +-  2%      +0.0        0.26 +-  3%  perf-profile.children.cycles-pp.current_time
      0.30            +0.0        0.35 +-  2%  perf-profile.children.cycles-pp.generic_pipe_buf_confirm
      0.52            +0.1        0.58        perf-profile.children.cycles-pp.entry_SYSCALL_64_stage2
      0.00            +0.1        0.08 +-  5%  perf-profile.children.cycles-pp.hrtick_update
     42.40            +0.3       42.69        perf-profile.children.cycles-pp.write
     31.86            +0.4       32.26        perf-profile.children.cycles-pp.__vfs_read
     24.40            +0.5       24.89        perf-profile.children.cycles-pp.pipe_wait
     20.40            +0.6       20.96 +-  2%  perf-profile.children.cycles-pp.try_to_wake_up
     22.30            +0.6       22.89        perf-profile.children.cycles-pp.schedule
     22.22            +0.6       22.84        perf-profile.children.cycles-pp.__schedule
      0.99 +- 36%      +0.9        1.94 +- 32%  perf-profile.children.cycles-pp.tracing_record_taskinfo
      3.30 +- 10%      +1.0        4.27 +- 13%  perf-profile.children.cycles-pp.ttwu_do_wakeup
      1.14 +- 31%      +1.1        2.24 +- 29%  perf-profile.children.cycles-pp.tracing_record_taskinfo_sched_switch
      1.59 +- 46%      +2.0        3.60 +- 36%  perf-profile.children.cycles-pp.trace_save_cmdline
      6.95            -0.2        6.70        perf-profile.self.cycles-pp.syscall_return_via_sysret
      5.19            -0.2        4.99        perf-profile.self.cycles-pp.__switch_to
      1.27            -0.1        1.12 +-  8%  perf-profile.self.cycles-pp.fsnotify
      1.49            -0.1        1.36        perf-profile.self.cycles-pp.select_task_rq_fair
      2.47            -0.1        2.37 +-  2%  perf-profile.self.cycles-pp.reweight_entity
      0.29            -0.1        0.19 +-  2%  perf-profile.self.cycles-pp.ksys_read
      1.50            -0.1        1.42        perf-profile.self.cycles-pp._raw_spin_unlock_irqrestore
      2.01            -0.1        1.93        perf-profile.self.cycles-pp.__calc_delta
      1.93            -0.1        1.86        perf-profile.self.cycles-pp._raw_spin_lock_irqsave
      1.47            -0.1        1.40        perf-profile.self.cycles-pp.dequeue_task_fair
      2.90            -0.1        2.84        perf-profile.self.cycles-pp.update_cfs_group
      1.29            -0.1        1.23        perf-profile.self.cycles-pp.do_syscall_64
      2.57            -0.1        2.52        perf-profile.self.cycles-pp.load_new_mm_cr3
      2.28            -0.1        2.23        perf-profile.self.cycles-pp.__switch_to_asm
      1.80            -0.1        1.75        perf-profile.self.cycles-pp.select_idle_sibling
      1.11            -0.0        1.07 +-  2%  perf-profile.self.cycles-pp.find_next_bit
      0.87            -0.0        0.83        perf-profile.self.cycles-pp.copy_user_generic_unrolled
      0.43            -0.0        0.39 +-  2%  perf-profile.self.cycles-pp.dequeue_entity
      1.70            -0.0        1.65        perf-profile.self.cycles-pp.native_write_msr
      0.92            -0.0        0.88 +-  2%  perf-profile.self.cycles-pp.account_entity_dequeue
      0.48            -0.0        0.44        perf-profile.self.cycles-pp.finish_task_switch
      0.77            -0.0        0.74        perf-profile.self.cycles-pp.___perf_sw_event
      0.66            -0.0        0.63        perf-profile.self.cycles-pp.account_entity_enqueue
      0.46 +-  2%      -0.0        0.43 +-  2%  perf-profile.self.cycles-pp.anon_pipe_buf_release
      0.32 +-  3%      -0.0        0.29 +-  4%  perf-profile.self.cycles-pp.__sb_start_write
      0.31 +-  2%      -0.0        0.28 +-  3%  perf-profile.self.cycles-pp.__list_del_entry_valid
      0.38            -0.0        0.36 +-  3%  perf-profile.self.cycles-pp.idle_cpu
      0.19 +-  4%      -0.0        0.17 +-  2%  perf-profile.self.cycles-pp.__fdget_pos
      0.50            -0.0        0.48        perf-profile.self.cycles-pp.__atime_needs_update
      0.23 +-  2%      -0.0        0.21 +-  3%  perf-profile.self.cycles-pp.touch_atime
      0.31            -0.0        0.30        perf-profile.self.cycles-pp.__x64_sys_read
      0.21 +-  2%      -0.0        0.20 +-  2%  perf-profile.self.cycles-pp.deactivate_task
      0.21 +-  2%      -0.0        0.19        perf-profile.self.cycles-pp.check_preempt_curr
      0.40            -0.0        0.39        perf-profile.self.cycles-pp.autoremove_wake_function
      0.40            -0.0        0.38        perf-profile.self.cycles-pp.copy_user_enhanced_fast_string
      0.27            -0.0        0.26        perf-profile.self.cycles-pp.pipe_wait
      0.13            -0.0        0.12 +-  4%  perf-profile.self.cycles-pp.timespec_trunc
      0.22 +-  2%      -0.0        0.20 +-  2%  perf-profile.self.cycles-pp.put_prev_entity
      0.09            -0.0        0.08        perf-profile.self.cycles-pp.iov_iter_init
      0.08            -0.0        0.07        perf-profile.self.cycles-pp.native_load_tls
      0.11            -0.0        0.10        perf-profile.self.cycles-pp.schedule
      0.12 +-  4%      +0.0        0.13        perf-profile.self.cycles-pp.copyin
      0.08 +-  5%      +0.0        0.10 +-  4%  perf-profile.self.cycles-pp.finish_wait
      0.18            +0.0        0.20 +-  2%  perf-profile.self.cycles-pp.ttwu_do_activate
      0.28 +-  2%      +0.0        0.30 +-  2%  perf-profile.self.cycles-pp._cond_resched
      0.24 +-  3%      +0.0        0.26 +-  3%  perf-profile.self.cycles-pp.rcu_all_qs
      0.05            +0.0        0.07 +-  6%  perf-profile.self.cycles-pp.default_wake_function
      0.08 +- 14%      +0.0        0.11 +- 14%  perf-profile.self.cycles-pp.tracing_record_taskinfo_sched_switch
      0.51            +0.0        0.55 +-  4%  perf-profile.self.cycles-pp.vfs_write
      0.30            +0.0        0.35 +-  2%  perf-profile.self.cycles-pp.generic_pipe_buf_confirm
      0.52            +0.1        0.58        perf-profile.self.cycles-pp.entry_SYSCALL_64_stage2
      0.00            +0.1        0.08 +-  5%  perf-profile.self.cycles-pp.hrtick_update
      1.97            +0.1        2.07 +-  2%  perf-profile.self.cycles-pp.switch_mm_irqs_off
      1.59 +- 46%      +2.0        3.60 +- 36%  perf-profile.self.cycles-pp.trace_save_cmdline

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/never/brk1/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :3           33%           1:3     kmsg.pstore:crypto_comp_decompress_failed,ret=
           :3           33%           1:3     kmsg.pstore:decompression_failed
         %stddev     %change         %stddev
             \          |                \  
    997317            -2.0%     977778        will-it-scale.per_process_ops
    957.00            -7.9%     881.00 +-  3%  will-it-scale.per_thread_ops
     18.42 +-  3%      -8.2%      16.90        will-it-scale.time.user_time
 1.917e+08            -2.0%  1.879e+08        will-it-scale.workload
     18.42 +-  3%      -8.2%      16.90        time.user_time
      0.30 +- 11%     -36.7%       0.19 +- 11%  turbostat.Pkg%pc2
     57539 +- 51%    +140.6%     138439 +- 31%  meminfo.CmaFree
    410877 +- 11%     -22.1%     320082 +- 22%  meminfo.DirectMap4k
    343575 +- 27%     +71.3%     588703 +- 31%  numa-numastat.node0.local_node
    374176 +- 24%     +63.3%     611007 +- 27%  numa-numastat.node0.numa_hit
   1056347 +-  4%     -39.9%     634843 +- 38%  numa-numastat.node3.local_node
   1060682 +-  4%     -39.0%     646862 +- 35%  numa-numastat.node3.numa_hit
     14383 +- 51%    +140.6%      34608 +- 31%  proc-vmstat.nr_free_cma
    179.00            +2.4%     183.33        proc-vmstat.nr_inactive_file
    179.00            +2.4%     183.33        proc-vmstat.nr_zone_inactive_file
    564483 +-  3%     -38.0%     350064 +- 36%  proc-vmstat.pgalloc_movable
   1811959           +10.8%    2008488 +-  5%  proc-vmstat.pgalloc_normal
      7153 +- 42%     -94.0%     431.33 +-119%  latency_stats.max.pipe_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      6627 +-141%    +380.5%      31843 +-110%  latency_stats.max.call_rwsem_down_write_failed_killable.do_mprotect_pkey.__x64_sys_mprotect.do_syscall_64.entry_SYSCALL_64_after_hwframe
     15244 +- 31%     -99.9%      15.00 +-141%  latency_stats.sum.call_rwsem_down_read_failed.__do_page_fault.do_page_fault.page_fault.__get_user_8.exit_robust_list.mm_release.do_exit.do_group_exit.get_signal.do_signal.exit_to_usermode_loop
      4301 +-117%     -83.7%     700.33 +-  6%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
     12153 +- 28%     -83.1%       2056 +- 70%  latency_stats.sum.pipe_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      6772 +-141%   +1105.8%      81665 +-127%  latency_stats.sum.call_rwsem_down_write_failed_killable.do_mprotect_pkey.__x64_sys_mprotect.do_syscall_64.entry_SYSCALL_64_after_hwframe
 2.465e+13            -1.3%  2.434e+13        perf-stat.branch-instructions
 2.691e+11            -2.1%  2.635e+11        perf-stat.branch-misses
 3.402e+13            -1.4%  3.355e+13        perf-stat.dTLB-loads
 1.694e+13            +1.4%  1.718e+13        perf-stat.dTLB-stores
      1.75 +- 50%      +4.7        6.45 +- 11%  perf-stat.iTLB-load-miss-rate%
 4.077e+08 +- 48%    +232.3%  1.355e+09 +- 11%  perf-stat.iTLB-load-misses
  2.31e+10 +-  2%     -14.9%  1.965e+10 +-  3%  perf-stat.iTLB-loads
 1.163e+14            -1.6%  1.144e+14        perf-stat.instructions
    346171 +- 36%     -75.3%      85575 +- 11%  perf-stat.instructions-per-iTLB-miss
 6.174e+08 +-  2%      -9.5%  5.589e+08        perf-stat.node-store-misses
    595.00 +- 10%     +31.4%     782.00 +-  3%  slabinfo.Acpi-State.active_objs
    595.00 +- 10%     +31.4%     782.00 +-  3%  slabinfo.Acpi-State.num_objs
      2831 +-  3%     -14.0%       2434 +-  5%  slabinfo.avtab_node.active_objs
      2831 +-  3%     -14.0%       2434 +-  5%  slabinfo.avtab_node.num_objs
    934.00           -10.9%     832.33 +-  5%  slabinfo.inotify_inode_mark.active_objs
    934.00           -10.9%     832.33 +-  5%  slabinfo.inotify_inode_mark.num_objs
      1232 +-  4%     +13.4%       1397 +-  6%  slabinfo.nsproxy.active_objs
      1232 +-  4%     +13.4%       1397 +-  6%  slabinfo.nsproxy.num_objs
    499.67 +- 12%     +24.8%     623.67 +- 10%  slabinfo.secpath_cache.active_objs
    499.67 +- 12%     +24.8%     623.67 +- 10%  slabinfo.secpath_cache.num_objs
     31393 +- 84%    +220.1%     100477 +- 21%  numa-meminfo.node0.Active
     31393 +- 84%    +220.1%     100477 +- 21%  numa-meminfo.node0.Active(anon)
     30013 +- 85%    +232.1%      99661 +- 21%  numa-meminfo.node0.AnonPages
     21603 +- 34%     -85.0%       3237 +-100%  numa-meminfo.node0.Inactive
     21528 +- 34%     -85.0%       3237 +-100%  numa-meminfo.node0.Inactive(anon)
     10247 +- 35%     -46.4%       5495        numa-meminfo.node0.Mapped
     35388 +- 14%     -41.6%      20670 +- 15%  numa-meminfo.node0.SReclaimable
     22911 +- 29%     -82.3%       4057 +- 84%  numa-meminfo.node0.Shmem
    117387 +-  9%     -22.5%      90986 +- 12%  numa-meminfo.node0.Slab
     68863 +- 67%     +77.7%     122351 +- 13%  numa-meminfo.node1.Active
     68863 +- 67%     +77.7%     122351 +- 13%  numa-meminfo.node1.Active(anon)
    228376           +22.3%     279406 +- 17%  numa-meminfo.node1.FilePages
      1481 +-116%   +1062.1%      17218 +- 39%  numa-meminfo.node1.Inactive
      1481 +-116%   +1062.0%      17216 +- 39%  numa-meminfo.node1.Inactive(anon)
      6593 +-  2%     +11.7%       7367 +-  3%  numa-meminfo.node1.KernelStack
    596227 +-  8%     +18.0%     703748 +-  4%  numa-meminfo.node1.MemUsed
     15298 +- 12%     +88.5%      28843 +- 36%  numa-meminfo.node1.SReclaimable
     52718 +-  9%     +21.0%      63810 +- 11%  numa-meminfo.node1.SUnreclaim
      1808 +- 97%   +2723.8%      51054 +- 97%  numa-meminfo.node1.Shmem
     68017 +-  5%     +36.2%      92654 +- 18%  numa-meminfo.node1.Slab
    125541 +- 29%     -64.9%      44024 +- 98%  numa-meminfo.node3.Active
    125137 +- 29%     -65.0%      43823 +- 98%  numa-meminfo.node3.Active(anon)
     93173 +- 25%     -87.8%      11381 +- 20%  numa-meminfo.node3.AnonPages
      9150 +-  5%      -9.3%       8301 +-  8%  numa-meminfo.node3.KernelStack
      7848 +- 84%    +220.0%      25118 +- 21%  numa-vmstat.node0.nr_active_anon
      7503 +- 85%    +232.1%      24914 +- 21%  numa-vmstat.node0.nr_anon_pages
      5381 +- 34%     -85.0%     809.00 +-100%  numa-vmstat.node0.nr_inactive_anon
      2559 +- 35%     -46.4%       1372        numa-vmstat.node0.nr_mapped
      5727 +- 29%     -82.3%       1014 +- 84%  numa-vmstat.node0.nr_shmem
      8846 +- 14%     -41.6%       5167 +- 15%  numa-vmstat.node0.nr_slab_reclaimable
      7848 +- 84%    +220.0%      25118 +- 21%  numa-vmstat.node0.nr_zone_active_anon
      5381 +- 34%     -85.0%     809.00 +-100%  numa-vmstat.node0.nr_zone_inactive_anon
      4821 +-  2%     +30.3%       6283 +- 15%  numa-vmstat.node1
     17215 +- 67%     +77.7%      30591 +- 13%  numa-vmstat.node1.nr_active_anon
     57093           +22.3%      69850 +- 17%  numa-vmstat.node1.nr_file_pages
    370.00 +-116%   +1061.8%       4298 +- 39%  numa-vmstat.node1.nr_inactive_anon
      6593 +-  2%     +11.7%       7366 +-  3%  numa-vmstat.node1.nr_kernel_stack
    451.67 +- 97%   +2725.6%      12762 +- 97%  numa-vmstat.node1.nr_shmem
      3824 +- 12%     +88.6%       7211 +- 36%  numa-vmstat.node1.nr_slab_reclaimable
     13179 +-  9%     +21.0%      15952 +- 11%  numa-vmstat.node1.nr_slab_unreclaimable
     17215 +- 67%     +77.7%      30591 +- 13%  numa-vmstat.node1.nr_zone_active_anon
    370.00 +-116%   +1061.8%       4298 +- 39%  numa-vmstat.node1.nr_zone_inactive_anon
    364789 +- 12%     +62.8%     593926 +- 34%  numa-vmstat.node1.numa_hit
    239539 +- 19%     +95.4%     468113 +- 43%  numa-vmstat.node1.numa_local
     71.00 +- 28%     +42.3%     101.00        numa-vmstat.node2.nr_mlock
     31285 +- 29%     -65.0%      10960 +- 98%  numa-vmstat.node3.nr_active_anon
     23292 +- 25%     -87.8%       2844 +- 19%  numa-vmstat.node3.nr_anon_pages
     14339 +- 52%    +141.1%      34566 +- 32%  numa-vmstat.node3.nr_free_cma
      9151 +-  5%      -9.3%       8299 +-  8%  numa-vmstat.node3.nr_kernel_stack
     31305 +- 29%     -64.9%      10975 +- 98%  numa-vmstat.node3.nr_zone_active_anon
    930131 +-  3%     -35.9%     596006 +- 34%  numa-vmstat.node3.numa_hit
    836455 +-  3%     -40.9%     493947 +- 44%  numa-vmstat.node3.numa_local
     75182 +- 58%     -83.8%      12160 +-  2%  sched_debug.cfs_rq:/.load.max
      6.65 +-  5%     -10.6%       5.94 +-  6%  sched_debug.cfs_rq:/.load_avg.avg
      0.16 +-  7%     +22.6%       0.20 +- 12%  sched_debug.cfs_rq:/.nr_running.stddev
      5.58 +- 24%    +427.7%      29.42 +- 93%  sched_debug.cfs_rq:/.nr_spread_over.max
      0.54 +- 15%    +306.8%       2.19 +- 86%  sched_debug.cfs_rq:/.nr_spread_over.stddev
      1.05 +- 25%     -65.1%       0.37 +- 71%  sched_debug.cfs_rq:/.removed.load_avg.avg
      9.62 +- 11%     -50.7%       4.74 +- 70%  sched_debug.cfs_rq:/.removed.load_avg.stddev
     48.70 +- 25%     -65.1%      17.02 +- 71%  sched_debug.cfs_rq:/.removed.runnable_sum.avg
    444.31 +- 11%     -50.7%     219.26 +- 70%  sched_debug.cfs_rq:/.removed.runnable_sum.stddev
      0.47 +- 13%     -60.9%       0.19 +- 71%  sched_debug.cfs_rq:/.removed.util_avg.avg
      4.47 +-  4%     -46.5%       2.39 +- 70%  sched_debug.cfs_rq:/.removed.util_avg.stddev
      1.64 +-  7%     +22.1%       2.00 +- 13%  sched_debug.cfs_rq:/.runnable_load_avg.stddev
     74653 +- 59%     -84.4%      11676        sched_debug.cfs_rq:/.runnable_weight.max
   -119169          -491.3%     466350 +- 27%  sched_debug.cfs_rq:/.spread0.avg
    517161 +- 30%    +145.8%    1271292 +- 23%  sched_debug.cfs_rq:/.spread0.max
    624.79 +-  5%     -14.2%     535.76 +-  7%  sched_debug.cfs_rq:/.util_est_enqueued.avg
    247.91 +- 32%     -99.8%       0.48 +-  8%  sched_debug.cfs_rq:/.util_est_enqueued.min
    179704 +-  3%     +30.4%     234297 +- 16%  sched_debug.cpu.avg_idle.stddev
      1.56 +-  9%     +24.4%       1.94 +- 14%  sched_debug.cpu.cpu_load[0].stddev
      1.50 +-  6%     +27.7%       1.91 +- 14%  sched_debug.cpu.cpu_load[1].stddev
      1.45 +-  3%     +30.8%       1.90 +- 14%  sched_debug.cpu.cpu_load[2].stddev
      1.43 +-  3%     +36.1%       1.95 +- 11%  sched_debug.cpu.cpu_load[3].stddev
      1.55 +-  7%     +43.5%       2.22 +-  7%  sched_debug.cpu.cpu_load[4].stddev
     10004 +-  3%     -11.6%       8839 +-  3%  sched_debug.cpu.curr->pid.avg
      1146 +- 26%     +52.2%       1745 +-  7%  sched_debug.cpu.curr->pid.min
      3162 +-  6%     +25.4%       3966 +- 11%  sched_debug.cpu.curr->pid.stddev
    403738 +-  3%     -11.7%     356696 +-  7%  sched_debug.cpu.nr_switches.max
      0.08 +- 21%     +78.2%       0.14 +- 14%  sched_debug.cpu.nr_uninterruptible.avg
    404435 +-  3%     -11.8%     356732 +-  7%  sched_debug.cpu.sched_count.max
      4.17            -0.3        3.87        perf-profile.calltrace.cycles-pp.kmem_cache_alloc.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      2.40            -0.2        2.17        perf-profile.calltrace.cycles-pp.vma_compute_subtree_gap.__vma_link_rb.vma_link.do_brk_flags.__x64_sys_brk
      7.58            -0.2        7.36        perf-profile.calltrace.cycles-pp.perf_event_mmap.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
     15.00            -0.2       14.81        perf-profile.calltrace.cycles-pp.syscall_return_via_sysret.brk
      7.83            -0.2        7.66        perf-profile.calltrace.cycles-pp.unmap_vmas.unmap_region.do_munmap.__x64_sys_brk.do_syscall_64
     28.66            -0.1       28.51        perf-profile.calltrace.cycles-pp.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
      2.15            -0.1        2.03        perf-profile.calltrace.cycles-pp.vma_compute_subtree_gap.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.07            -0.1        0.99        perf-profile.calltrace.cycles-pp.memcpy_erms.strlcpy.perf_event_mmap.do_brk_flags.__x64_sys_brk
      1.03            -0.1        0.95        perf-profile.calltrace.cycles-pp.kmem_cache_free.remove_vma.do_munmap.__x64_sys_brk.do_syscall_64
      7.33            -0.1        7.25        perf-profile.calltrace.cycles-pp.unmap_page_range.unmap_vmas.unmap_region.do_munmap.__x64_sys_brk
      0.76            -0.1        0.69        perf-profile.calltrace.cycles-pp.__vm_enough_memory.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
     11.85            -0.1       11.77        perf-profile.calltrace.cycles-pp.unmap_region.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.64            -0.1        1.57        perf-profile.calltrace.cycles-pp.strlcpy.perf_event_mmap.do_brk_flags.__x64_sys_brk.do_syscall_64
      1.06            -0.1        0.99        perf-profile.calltrace.cycles-pp.__indirect_thunk_start.brk
      0.73            -0.1        0.67        perf-profile.calltrace.cycles-pp.sync_mm_rss.unmap_page_range.unmap_vmas.unmap_region.do_munmap
      4.59            -0.1        4.52        perf-profile.calltrace.cycles-pp.security_vm_enough_memory_mm.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      2.82            -0.1        2.76        perf-profile.calltrace.cycles-pp.selinux_vm_enough_memory.security_vm_enough_memory_mm.do_brk_flags.__x64_sys_brk.do_syscall_64
      2.89            -0.1        2.84        perf-profile.calltrace.cycles-pp.down_write_killable.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
      3.37            -0.1        3.32        perf-profile.calltrace.cycles-pp.get_unmapped_area.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.99            -0.0        1.94        perf-profile.calltrace.cycles-pp.cred_has_capability.selinux_vm_enough_memory.security_vm_enough_memory_mm.do_brk_flags.__x64_sys_brk
      2.32            -0.0        2.27        perf-profile.calltrace.cycles-pp.perf_iterate_sb.perf_event_mmap.do_brk_flags.__x64_sys_brk.do_syscall_64
      1.88            -0.0        1.84        perf-profile.calltrace.cycles-pp.security_mmap_addr.get_unmapped_area.do_brk_flags.__x64_sys_brk.do_syscall_64
      0.77            -0.0        0.73        perf-profile.calltrace.cycles-pp._raw_spin_lock.unmap_page_range.unmap_vmas.unmap_region.do_munmap
      1.62            -0.0        1.59        perf-profile.calltrace.cycles-pp.memset_erms.kmem_cache_alloc.do_brk_flags.__x64_sys_brk.do_syscall_64
      0.81            -0.0        0.79        perf-profile.calltrace.cycles-pp.___might_sleep.down_write_killable.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.66            -0.0        0.64        perf-profile.calltrace.cycles-pp.arch_get_unmapped_area_topdown.brk
      0.72            +0.0        0.74        perf-profile.calltrace.cycles-pp.do_munmap.brk
      0.90            +0.0        0.93        perf-profile.calltrace.cycles-pp.___might_sleep.unmap_page_range.unmap_vmas.unmap_region.do_munmap
      4.40            +0.1        4.47        perf-profile.calltrace.cycles-pp.find_vma.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.96            +0.1        2.09        perf-profile.calltrace.cycles-pp.vmacache_find.find_vma.do_munmap.__x64_sys_brk.do_syscall_64
      0.52 +-  2%      +0.2        0.68        perf-profile.calltrace.cycles-pp.__vma_link_rb.brk
      0.35 +- 70%      +0.2        0.54 +-  2%  perf-profile.calltrace.cycles-pp.find_vma.brk
      2.20            +0.3        2.50        perf-profile.calltrace.cycles-pp.remove_vma.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
     64.62            +0.3       64.94        perf-profile.calltrace.cycles-pp.entry_SYSCALL_64_after_hwframe.brk
     60.53            +0.4       60.92        perf-profile.calltrace.cycles-pp.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
     63.20            +0.4       63.60        perf-profile.calltrace.cycles-pp.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
      3.73            +0.5        4.26        perf-profile.calltrace.cycles-pp.vma_link.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00            +0.6        0.56        perf-profile.calltrace.cycles-pp.free_pgtables.unmap_region.do_munmap.__x64_sys_brk.do_syscall_64
     24.54            +0.6       25.14        perf-profile.calltrace.cycles-pp.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
      0.00            +0.6        0.64        perf-profile.calltrace.cycles-pp.put_vma.remove_vma.do_munmap.__x64_sys_brk.do_syscall_64
      0.71            +0.6        1.36        perf-profile.calltrace.cycles-pp.__vma_rb_erase.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00            +0.7        0.70        perf-profile.calltrace.cycles-pp._raw_write_lock.__vma_rb_erase.do_munmap.__x64_sys_brk.do_syscall_64
      3.10            +0.7        3.82        perf-profile.calltrace.cycles-pp.__vma_link_rb.vma_link.do_brk_flags.__x64_sys_brk.do_syscall_64
      0.00            +0.8        0.76        perf-profile.calltrace.cycles-pp._raw_write_lock.__vma_link_rb.vma_link.do_brk_flags.__x64_sys_brk
      0.00            +0.8        0.85        perf-profile.calltrace.cycles-pp.__vma_merge.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      5.09            -0.5        4.62        perf-profile.children.cycles-pp.vma_compute_subtree_gap
      4.54            -0.3        4.21        perf-profile.children.cycles-pp.kmem_cache_alloc
      8.11            -0.2        7.89        perf-profile.children.cycles-pp.perf_event_mmap
      8.05            -0.2        7.85        perf-profile.children.cycles-pp.unmap_vmas
     15.01            -0.2       14.81        perf-profile.children.cycles-pp.syscall_return_via_sysret
     29.20            -0.1       29.06        perf-profile.children.cycles-pp.do_brk_flags
      1.11            -0.1        1.00        perf-profile.children.cycles-pp.kmem_cache_free
     12.28            -0.1       12.17        perf-profile.children.cycles-pp.unmap_region
      7.83            -0.1        7.74        perf-profile.children.cycles-pp.unmap_page_range
      0.87 +-  3%      -0.1        0.79        perf-profile.children.cycles-pp.__vm_enough_memory
      1.29            -0.1        1.22        perf-profile.children.cycles-pp.__indirect_thunk_start
      1.81            -0.1        1.74        perf-profile.children.cycles-pp.strlcpy
      4.65            -0.1        4.58        perf-profile.children.cycles-pp.security_vm_enough_memory_mm
      3.08            -0.1        3.02        perf-profile.children.cycles-pp.down_write_killable
      2.88            -0.1        2.82        perf-profile.children.cycles-pp.selinux_vm_enough_memory
      0.73            -0.1        0.67        perf-profile.children.cycles-pp.sync_mm_rss
      3.65            -0.1        3.59        perf-profile.children.cycles-pp.get_unmapped_area
      2.26            -0.1        2.20        perf-profile.children.cycles-pp.cred_has_capability
      1.12            -0.1        1.07        perf-profile.children.cycles-pp.memcpy_erms
      0.39            -0.0        0.35        perf-profile.children.cycles-pp.__rb_insert_augmented
      2.52            -0.0        2.48        perf-profile.children.cycles-pp.perf_iterate_sb
      2.13            -0.0        2.09        perf-profile.children.cycles-pp.security_mmap_addr
      0.55 +-  2%      -0.0        0.52        perf-profile.children.cycles-pp.unmap_single_vma
      1.62            -0.0        1.59        perf-profile.children.cycles-pp.memset_erms
      0.13 +-  3%      -0.0        0.11 +-  4%  perf-profile.children.cycles-pp.__vma_link_file
      0.80            -0.0        0.77        perf-profile.children.cycles-pp._raw_spin_lock
      0.43            -0.0        0.41        perf-profile.children.cycles-pp.strlen
      0.07 +-  6%      -0.0        0.06 +-  8%  perf-profile.children.cycles-pp.should_failslab
      0.43            -0.0        0.42        perf-profile.children.cycles-pp.may_expand_vm
      0.15            +0.0        0.16        perf-profile.children.cycles-pp.__vma_link_list
      0.45            +0.0        0.47        perf-profile.children.cycles-pp.rcu_all_qs
      0.81            +0.1        0.89        perf-profile.children.cycles-pp.free_pgtables
      6.35            +0.1        6.49        perf-profile.children.cycles-pp.find_vma
      2.28            +0.2        2.45        perf-profile.children.cycles-pp.vmacache_find
     64.66            +0.3       64.98        perf-profile.children.cycles-pp.entry_SYSCALL_64_after_hwframe
      2.42            +0.3        2.76        perf-profile.children.cycles-pp.remove_vma
     61.77            +0.4       62.13        perf-profile.children.cycles-pp.__x64_sys_brk
     63.40            +0.4       63.79        perf-profile.children.cycles-pp.do_syscall_64
      1.27            +0.4        1.72        perf-profile.children.cycles-pp.__vma_rb_erase
      4.02            +0.5        4.53        perf-profile.children.cycles-pp.vma_link
     25.26            +0.6       25.89        perf-profile.children.cycles-pp.do_munmap
      0.00            +0.7        0.70        perf-profile.children.cycles-pp.put_vma
      3.80            +0.7        4.53        perf-profile.children.cycles-pp.__vma_link_rb
      0.00            +1.2        1.24        perf-profile.children.cycles-pp.__vma_merge
      0.00            +1.5        1.51        perf-profile.children.cycles-pp._raw_write_lock
      5.07            -0.5        4.60        perf-profile.self.cycles-pp.vma_compute_subtree_gap
      0.59            -0.2        0.38        perf-profile.self.cycles-pp.remove_vma
     15.01            -0.2       14.81        perf-profile.self.cycles-pp.syscall_return_via_sysret
      3.15            -0.2        2.96        perf-profile.self.cycles-pp.do_munmap
      0.98            -0.1        0.87        perf-profile.self.cycles-pp.__vma_rb_erase
      1.10            -0.1        0.99        perf-profile.self.cycles-pp.kmem_cache_free
      0.68            -0.1        0.58        perf-profile.self.cycles-pp.__vm_enough_memory
      0.42            -0.1        0.33        perf-profile.self.cycles-pp.unmap_vmas
      3.62            -0.1        3.53        perf-profile.self.cycles-pp.perf_event_mmap
      1.41            -0.1        1.34        perf-profile.self.cycles-pp.entry_SYSCALL_64_after_hwframe
      1.29            -0.1        1.22        perf-profile.self.cycles-pp.__indirect_thunk_start
      0.73            -0.1        0.66        perf-profile.self.cycles-pp.sync_mm_rss
      2.96            -0.1        2.90        perf-profile.self.cycles-pp.__x64_sys_brk
      3.24            -0.1        3.19        perf-profile.self.cycles-pp.brk
      1.11            -0.0        1.07        perf-profile.self.cycles-pp.memcpy_erms
      0.53 +-  3%      -0.0        0.49 +-  2%  perf-profile.self.cycles-pp.vma_link
      0.73            -0.0        0.69        perf-profile.self.cycles-pp.unmap_region
      1.66            -0.0        1.61        perf-profile.self.cycles-pp.down_write_killable
      0.39            -0.0        0.35        perf-profile.self.cycles-pp.__rb_insert_augmented
      1.74            -0.0        1.71        perf-profile.self.cycles-pp.kmem_cache_alloc
      0.55 +-  2%      -0.0        0.52        perf-profile.self.cycles-pp.unmap_single_vma
      1.61            -0.0        1.59        perf-profile.self.cycles-pp.memset_erms
      0.80            -0.0        0.77        perf-profile.self.cycles-pp._raw_spin_lock
      0.13            -0.0        0.11 +-  4%  perf-profile.self.cycles-pp.__vma_link_file
      0.43            -0.0        0.41        perf-profile.self.cycles-pp.strlen
      0.07 +-  6%      -0.0        0.06 +-  8%  perf-profile.self.cycles-pp.should_failslab
      0.81            -0.0        0.79        perf-profile.self.cycles-pp.tlb_finish_mmu
      0.15            +0.0        0.16        perf-profile.self.cycles-pp.__vma_link_list
      0.45            +0.0        0.47        perf-profile.self.cycles-pp.rcu_all_qs
      0.71            +0.0        0.72        perf-profile.self.cycles-pp.strlcpy
      0.51            +0.1        0.56        perf-profile.self.cycles-pp.free_pgtables
      1.41            +0.1        1.48        perf-profile.self.cycles-pp.__vma_link_rb
      2.27            +0.2        2.44        perf-profile.self.cycles-pp.vmacache_find
      0.00            +0.7        0.69        perf-profile.self.cycles-pp.put_vma
      0.00            +1.2        1.23        perf-profile.self.cycles-pp.__vma_merge
      0.00            +1.5        1.50        perf-profile.self.cycles-pp._raw_write_lock

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/always/brk1/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :3           33%           1:3     dmesg.WARNING:stack_going_in_the_wrong_direction?ip=schedule_tail/0x
           :3           33%           1:3     kmsg.DHCP/BOOTP:Reply_not_for_us_on_eth#,op[#]xid[#]
         %stddev     %change         %stddev
             \          |                \  
    998475            -2.2%     976893        will-it-scale.per_process_ops
    625.87            -2.3%     611.42        will-it-scale.time.elapsed_time
    625.87            -2.3%     611.42        will-it-scale.time.elapsed_time.max
      8158            -1.9%       8000        will-it-scale.time.maximum_resident_set_size
     18.42 +-  2%     -11.9%      16.24        will-it-scale.time.user_time
  34349225 +- 13%     -14.5%   29371024 +- 17%  will-it-scale.time.voluntary_context_switches
 1.919e+08            -2.2%  1.877e+08        will-it-scale.workload
      1639 +- 23%     -18.4%       1337 +- 30%  meminfo.Mlocked
     17748 +- 82%    +103.1%      36051        numa-numastat.node3.other_node
  33410486 +- 14%     -14.8%   28449258 +- 18%  cpuidle.C1.usage
    698749 +- 15%     -18.0%     573307 +- 20%  cpuidle.POLL.usage
   3013702 +- 14%     -15.1%    2559405 +- 17%  softirqs.SCHED
  54361293 +-  2%     -19.0%   44044816 +-  2%  softirqs.TIMER
  33408303 +- 14%     -14.9%   28447123 +- 18%  turbostat.C1
      0.34 +- 16%     -52.0%       0.16 +- 15%  turbostat.Pkg%pc2
      1310 +- 74%    +412.1%       6710 +- 58%  irq_exception_noise.__do_page_fault.samples
      3209 +- 74%    +281.9%      12258 +- 53%  irq_exception_noise.__do_page_fault.sum
    600.67 +-132%     -96.0%      24.00 +- 23%  irq_exception_noise.irq_nr
     99557 +-  7%     -24.0%      75627 +-  7%  irq_exception_noise.softirq_nr
     41424 +-  9%     -24.6%      31253 +-  6%  irq_exception_noise.softirq_time
    625.87            -2.3%     611.42        time.elapsed_time
    625.87            -2.3%     611.42        time.elapsed_time.max
      8158            -1.9%       8000        time.maximum_resident_set_size
     18.42 +-  2%     -11.9%      16.24        time.user_time
  34349225 +- 13%     -14.5%   29371024 +- 17%  time.voluntary_context_switches
    988.00 +-  8%     +14.5%       1131 +-  2%  slabinfo.Acpi-ParseExt.active_objs
    988.00 +-  8%     +14.5%       1131 +-  2%  slabinfo.Acpi-ParseExt.num_objs
      2384 +-  3%     +21.1%       2888 +- 11%  slabinfo.pool_workqueue.active_objs
      2474 +-  2%     +20.4%       2979 +- 11%  slabinfo.pool_workqueue.num_objs
    490.33 +- 10%     -19.2%     396.00 +- 11%  slabinfo.secpath_cache.active_objs
    490.33 +- 10%     -19.2%     396.00 +- 11%  slabinfo.secpath_cache.num_objs
      1123 +-  7%     +14.2%       1282 +-  3%  slabinfo.skbuff_fclone_cache.active_objs
      1123 +-  7%     +14.2%       1282 +-  3%  slabinfo.skbuff_fclone_cache.num_objs
      1.09            -0.0        1.07        perf-stat.branch-miss-rate%
 2.691e+11            -2.4%  2.628e+11        perf-stat.branch-misses
  71981351 +- 12%     -13.8%   62013509 +- 16%  perf-stat.context-switches
 1.697e+13            +1.1%  1.715e+13        perf-stat.dTLB-stores
      2.36 +- 29%      +4.4        6.76 +- 11%  perf-stat.iTLB-load-miss-rate%
  5.21e+08 +- 28%    +194.8%  1.536e+09 +- 10%  perf-stat.iTLB-load-misses
    239983 +- 24%     -68.4%      75819 +- 11%  perf-stat.instructions-per-iTLB-miss
   3295653 +-  2%      -6.3%    3088753 +-  3%  perf-stat.node-stores
    606239            +1.1%     612799        perf-stat.path-length
      3755 +- 28%     -37.5%       2346 +- 52%  sched_debug.cfs_rq:/.exec_clock.stddev
     10.45 +-  4%     +24.3%      12.98 +- 18%  sched_debug.cfs_rq:/.load_avg.stddev
      6243 +- 46%     -38.6%       3831 +- 78%  sched_debug.cpu.load.stddev
    867.80 +-  7%     +25.3%       1087 +-  6%  sched_debug.cpu.nr_load_updates.stddev
    395898 +-  3%     -11.1%     352071 +-  7%  sched_debug.cpu.nr_switches.max
    -13.33           -21.1%     -10.52        sched_debug.cpu.nr_uninterruptible.min
    395674 +-  3%     -11.1%     351762 +-  7%  sched_debug.cpu.sched_count.max
     33152 +-  4%     -12.8%      28899        sched_debug.cpu.ttwu_count.min
      0.03 +- 20%     +77.7%       0.05 +- 15%  sched_debug.rt_rq:/.rt_time.max
     89523            +1.8%      91099        proc-vmstat.nr_active_anon
    409.67 +- 23%     -18.4%     334.33 +- 30%  proc-vmstat.nr_mlock
     89530            +1.8%      91117        proc-vmstat.nr_zone_active_anon
   2337130            -2.2%    2286775        proc-vmstat.numa_hit
   2229090            -2.3%    2178626        proc-vmstat.numa_local
      8460 +- 39%     -75.5%       2076 +- 53%  proc-vmstat.numa_pages_migrated
     28643 +- 55%     -83.5%       4727 +- 58%  proc-vmstat.numa_pte_updates
   2695806            -1.8%    2646639        proc-vmstat.pgfault
   2330191            -2.1%    2281197        proc-vmstat.pgfree
      8460 +- 39%     -75.5%       2076 +- 53%  proc-vmstat.pgmigrate_success
    237651 +-  2%     +31.3%     312092 +- 16%  numa-meminfo.node0.FilePages
      8059 +-  2%     +10.7%       8925 +-  7%  numa-meminfo.node0.KernelStack
      6830 +- 25%     +48.8%      10164 +- 35%  numa-meminfo.node0.Mapped
      1612 +- 21%     +70.0%       2740 +- 19%  numa-meminfo.node0.PageTables
     10772 +- 65%    +679.4%      83962 +- 59%  numa-meminfo.node0.Shmem
    163195 +- 15%     -36.9%     103036 +- 32%  numa-meminfo.node1.Active
    163195 +- 15%     -36.9%     103036 +- 32%  numa-meminfo.node1.Active(anon)
      1730 +-  4%     +33.9%       2317 +- 14%  numa-meminfo.node1.PageTables
     55778 +- 19%     +32.5%      73910 +-  8%  numa-meminfo.node1.SUnreclaim
      2671 +- 16%     -45.0%       1469 +- 15%  numa-meminfo.node2.PageTables
     61537 +- 13%     -17.7%      50647 +-  3%  numa-meminfo.node2.SUnreclaim
     48644 +- 94%    +149.8%     121499 +- 11%  numa-meminfo.node3.Active
     48440 +- 94%    +150.4%     121295 +- 11%  numa-meminfo.node3.Active(anon)
     11832 +- 79%     -91.5%       1008 +- 67%  numa-meminfo.node3.Inactive
     11597 +- 82%     -93.3%     772.00 +- 82%  numa-meminfo.node3.Inactive(anon)
     10389 +- 32%     -43.0%       5921 +-  6%  numa-meminfo.node3.Mapped
     33704 +- 24%     -44.2%      18792 +- 15%  numa-meminfo.node3.SReclaimable
    104733 +- 14%     -25.3%      78275 +-  8%  numa-meminfo.node3.Slab
    139329 +-133%     -99.8%     241.67 +- 79%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
      5403 +-139%     -97.5%     137.67 +- 71%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
    165968 +-101%     -61.9%      63304 +- 58%  latency_stats.avg.max
     83.00        +12810.4%      10715 +-140%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat.filename_lookup
    102.67 +-  6%  +18845.5%      19450 +-140%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
    136.33 +- 16%  +25043.5%      34279 +-141%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     18497 +-141%    -100.0%       0.00        latency_stats.max.call_rwsem_down_write_failed_killable.vm_mmap_pgoff.ksys_mmap_pgoff.do_syscall_64.entry_SYSCALL_64_after_hwframe
    140500 +-131%     -99.8%     247.00 +- 78%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
      5403 +-139%     -97.5%     137.67 +- 71%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     87.33 +-  5%  +23963.0%      21015 +-140%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat.filename_lookup
    136.33 +- 16%  +25043.5%      34279 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
    149.33 +- 14%  +25485.9%      38208 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
     18761 +-141%    -100.0%       0.00        latency_stats.sum.call_rwsem_down_write_failed_killable.vm_mmap_pgoff.ksys_mmap_pgoff.do_syscall_64.entry_SYSCALL_64_after_hwframe
     23363 +-114%    -100.0%       0.00        latency_stats.sum.call_rwsem_down_read_failed.__do_page_fault.do_page_fault.page_fault.__get_user_8.exit_robust_list.mm_release.do_exit.do_group_exit.get_signal.do_signal.exit_to_usermode_loop
    144810 +-125%     -99.8%     326.67 +- 70%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
      5403 +-139%     -97.5%     137.67 +- 71%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     59698 +- 98%     -78.0%      13110 +-141%  latency_stats.sum.call_rwsem_down_read_failed.do_exit.do_group_exit.get_signal.do_signal.exit_to_usermode_loop.do_syscall_64.entry_SYSCALL_64_after_hwframe
    166.33        +12768.5%      21404 +-140%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_access.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat.filename_lookup
    825.00 +-  6%  +18761.7%     155609 +-140%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
    136.33 +- 16%  +25043.5%      34279 +-141%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     59412 +-  2%     +31.3%      78021 +- 16%  numa-vmstat.node0.nr_file_pages
      8059 +-  2%     +10.7%       8923 +-  7%  numa-vmstat.node0.nr_kernel_stack
      1701 +- 25%     +49.1%       2536 +- 35%  numa-vmstat.node0.nr_mapped
    402.33 +- 21%     +70.0%     684.00 +- 19%  numa-vmstat.node0.nr_page_table_pages
      2692 +- 65%    +679.5%      20988 +- 59%  numa-vmstat.node0.nr_shmem
    622587 +- 36%     +37.7%     857545 +- 13%  numa-vmstat.node0.numa_local
     40797 +- 15%     -36.9%      25757 +- 32%  numa-vmstat.node1.nr_active_anon
    432.00 +-  4%     +33.9%     578.33 +- 14%  numa-vmstat.node1.nr_page_table_pages
     13944 +- 19%     +32.5%      18477 +-  8%  numa-vmstat.node1.nr_slab_unreclaimable
     40797 +- 15%     -36.9%      25757 +- 32%  numa-vmstat.node1.nr_zone_active_anon
    625073 +- 26%     +29.4%     808657 +- 18%  numa-vmstat.node1.numa_hit
    503969 +- 34%     +39.2%     701446 +- 23%  numa-vmstat.node1.numa_local
    137.33 +- 40%     -49.0%      70.00 +- 29%  numa-vmstat.node2.nr_mlock
    667.67 +- 17%     -45.1%     366.33 +- 15%  numa-vmstat.node2.nr_page_table_pages
     15384 +- 13%     -17.7%      12662 +-  3%  numa-vmstat.node2.nr_slab_unreclaimable
     12114 +- 94%    +150.3%      30326 +- 11%  numa-vmstat.node3.nr_active_anon
      2887 +- 83%     -93.4%     190.00 +- 82%  numa-vmstat.node3.nr_inactive_anon
      2632 +- 30%     -39.2%       1600 +-  5%  numa-vmstat.node3.nr_mapped
    101.00           -30.0%      70.67 +- 29%  numa-vmstat.node3.nr_mlock
      8425 +- 24%     -44.2%       4697 +- 15%  numa-vmstat.node3.nr_slab_reclaimable
     12122 +- 94%    +150.3%      30346 +- 11%  numa-vmstat.node3.nr_zone_active_anon
      2887 +- 83%     -93.4%     190.00 +- 82%  numa-vmstat.node3.nr_zone_inactive_anon
    106945 +- 13%     +17.4%     125554        numa-vmstat.node3.numa_other
      4.17            -0.3        3.82        perf-profile.calltrace.cycles-pp.kmem_cache_alloc.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
     15.02            -0.3       14.77        perf-profile.calltrace.cycles-pp.syscall_return_via_sysret.brk
      2.42            -0.2        2.18        perf-profile.calltrace.cycles-pp.vma_compute_subtree_gap.__vma_link_rb.vma_link.do_brk_flags.__x64_sys_brk
      7.60            -0.2        7.39        perf-profile.calltrace.cycles-pp.perf_event_mmap.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      7.79            -0.2        7.63        perf-profile.calltrace.cycles-pp.unmap_vmas.unmap_region.do_munmap.__x64_sys_brk.do_syscall_64
      0.82 +-  9%      -0.1        0.68        perf-profile.calltrace.cycles-pp.__vm_enough_memory.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      2.13            -0.1        2.00        perf-profile.calltrace.cycles-pp.vma_compute_subtree_gap.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.05            -0.1        0.95        perf-profile.calltrace.cycles-pp.kmem_cache_free.remove_vma.do_munmap.__x64_sys_brk.do_syscall_64
      7.31            -0.1        7.21        perf-profile.calltrace.cycles-pp.unmap_page_range.unmap_vmas.unmap_region.do_munmap.__x64_sys_brk
      0.74            -0.1        0.67        perf-profile.calltrace.cycles-pp.sync_mm_rss.unmap_page_range.unmap_vmas.unmap_region.do_munmap
      1.06            -0.1        1.00        perf-profile.calltrace.cycles-pp.memcpy_erms.strlcpy.perf_event_mmap.do_brk_flags.__x64_sys_brk
      3.38            -0.1        3.33        perf-profile.calltrace.cycles-pp.get_unmapped_area.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.05            -0.0        1.00 +-  2%  perf-profile.calltrace.cycles-pp.__indirect_thunk_start.brk
      2.34            -0.0        2.29        perf-profile.calltrace.cycles-pp.perf_iterate_sb.perf_event_mmap.do_brk_flags.__x64_sys_brk.do_syscall_64
      1.64            -0.0        1.59        perf-profile.calltrace.cycles-pp.strlcpy.perf_event_mmap.do_brk_flags.__x64_sys_brk.do_syscall_64
      1.89            -0.0        1.86        perf-profile.calltrace.cycles-pp.security_mmap_addr.get_unmapped_area.do_brk_flags.__x64_sys_brk.do_syscall_64
      0.76            -0.0        0.73        perf-profile.calltrace.cycles-pp._raw_spin_lock.unmap_page_range.unmap_vmas.unmap_region.do_munmap
      0.57 +-  2%      -0.0        0.55        perf-profile.calltrace.cycles-pp.selinux_mmap_addr.security_mmap_addr.get_unmapped_area.do_brk_flags.__x64_sys_brk
      0.54 +-  2%      +0.0        0.56        perf-profile.calltrace.cycles-pp.do_brk_flags.brk
      0.72            +0.0        0.76 +-  2%  perf-profile.calltrace.cycles-pp.do_munmap.brk
      4.38            +0.1        4.43        perf-profile.calltrace.cycles-pp.find_vma.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.96            +0.1        2.04        perf-profile.calltrace.cycles-pp.vmacache_find.find_vma.do_munmap.__x64_sys_brk.do_syscall_64
      0.53            +0.2        0.68        perf-profile.calltrace.cycles-pp.__vma_link_rb.brk
      2.21            +0.3        2.51        perf-profile.calltrace.cycles-pp.remove_vma.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
     64.44            +0.5       64.90        perf-profile.calltrace.cycles-pp.entry_SYSCALL_64_after_hwframe.brk
     63.04            +0.5       63.54        perf-profile.calltrace.cycles-pp.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
     60.37            +0.5       60.88        perf-profile.calltrace.cycles-pp.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
      3.75            +0.5        4.29        perf-profile.calltrace.cycles-pp.vma_link.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00            +0.6        0.57        perf-profile.calltrace.cycles-pp.free_pgtables.unmap_region.do_munmap.__x64_sys_brk.do_syscall_64
      0.00            +0.6        0.64        perf-profile.calltrace.cycles-pp.put_vma.remove_vma.do_munmap.__x64_sys_brk.do_syscall_64
      0.72            +0.7        1.37        perf-profile.calltrace.cycles-pp.__vma_rb_erase.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
     24.42            +0.7       25.08        perf-profile.calltrace.cycles-pp.do_munmap.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe.brk
      0.00            +0.7        0.71        perf-profile.calltrace.cycles-pp._raw_write_lock.__vma_rb_erase.do_munmap.__x64_sys_brk.do_syscall_64
      3.12            +0.7        3.84        perf-profile.calltrace.cycles-pp.__vma_link_rb.vma_link.do_brk_flags.__x64_sys_brk.do_syscall_64
      0.00            +0.8        0.77        perf-profile.calltrace.cycles-pp._raw_write_lock.__vma_link_rb.vma_link.do_brk_flags.__x64_sys_brk
      0.00            +0.9        0.85        perf-profile.calltrace.cycles-pp.__vma_merge.do_brk_flags.__x64_sys_brk.do_syscall_64.entry_SYSCALL_64_after_hwframe
      5.10            -0.5        4.60        perf-profile.children.cycles-pp.vma_compute_subtree_gap
      4.53            -0.3        4.18        perf-profile.children.cycles-pp.kmem_cache_alloc
     15.03            -0.3       14.77        perf-profile.children.cycles-pp.syscall_return_via_sysret
      8.13            -0.2        7.92        perf-profile.children.cycles-pp.perf_event_mmap
      8.01            -0.2        7.81        perf-profile.children.cycles-pp.unmap_vmas
      0.97 +- 14%      -0.2        0.78        perf-profile.children.cycles-pp.__vm_enough_memory
      1.13            -0.1        1.00        perf-profile.children.cycles-pp.kmem_cache_free
      7.82            -0.1        7.70        perf-profile.children.cycles-pp.unmap_page_range
     12.23            -0.1       12.13        perf-profile.children.cycles-pp.unmap_region
      0.74            -0.1        0.67        perf-profile.children.cycles-pp.sync_mm_rss
      3.06            -0.1        3.00        perf-profile.children.cycles-pp.down_write_killable
      0.40 +-  2%      -0.1        0.34        perf-profile.children.cycles-pp.__rb_insert_augmented
      1.29            -0.1        1.23        perf-profile.children.cycles-pp.__indirect_thunk_start
      2.54            -0.1        2.49        perf-profile.children.cycles-pp.perf_iterate_sb
      3.66            -0.0        3.61        perf-profile.children.cycles-pp.get_unmapped_area
      1.80            -0.0        1.75        perf-profile.children.cycles-pp.strlcpy
      0.53 +-  2%      -0.0        0.49 +-  2%  perf-profile.children.cycles-pp.cap_capable
      1.57            -0.0        1.53        perf-profile.children.cycles-pp.arch_get_unmapped_area_topdown
      1.11            -0.0        1.08        perf-profile.children.cycles-pp.memcpy_erms
      0.13            -0.0        0.10        perf-profile.children.cycles-pp.__vma_link_file
      0.55            -0.0        0.52        perf-profile.children.cycles-pp.unmap_single_vma
      1.47            -0.0        1.44        perf-profile.children.cycles-pp.cap_vm_enough_memory
      2.14            -0.0        2.12        perf-profile.children.cycles-pp.security_mmap_addr
      0.32            -0.0        0.30        perf-profile.children.cycles-pp.userfaultfd_unmap_complete
      1.25            -0.0        1.23        perf-profile.children.cycles-pp.up_write
      0.50            -0.0        0.49        perf-profile.children.cycles-pp.userfaultfd_unmap_prep
      0.27            -0.0        0.26        perf-profile.children.cycles-pp.tlb_flush_mmu_free
      1.14            -0.0        1.12        perf-profile.children.cycles-pp.__might_sleep
      0.07            -0.0        0.06        perf-profile.children.cycles-pp.should_failslab
      0.72            +0.0        0.74        perf-profile.children.cycles-pp._cond_resched
      0.45            +0.0        0.47        perf-profile.children.cycles-pp.rcu_all_qs
      0.15 +-  3%      +0.0        0.17 +-  4%  perf-profile.children.cycles-pp.__vma_link_list
      0.15 +-  5%      +0.0        0.18 +-  5%  perf-profile.children.cycles-pp.tick_sched_timer
      0.05 +-  8%      +0.1        0.12 +- 17%  perf-profile.children.cycles-pp.perf_mux_hrtimer_handler
      0.80            +0.1        0.89        perf-profile.children.cycles-pp.free_pgtables
      0.22 +-  7%      +0.1        0.31 +-  9%  perf-profile.children.cycles-pp.__hrtimer_run_queues
      0.00            +0.1        0.11 +- 15%  perf-profile.children.cycles-pp.clockevents_program_event
      6.34            +0.1        6.47        perf-profile.children.cycles-pp.find_vma
      2.27            +0.1        2.40        perf-profile.children.cycles-pp.vmacache_find
      0.40 +-  4%      +0.2        0.58 +-  5%  perf-profile.children.cycles-pp.apic_timer_interrupt
      0.40 +-  4%      +0.2        0.58 +-  5%  perf-profile.children.cycles-pp.smp_apic_timer_interrupt
      0.37 +-  4%      +0.2        0.54 +-  5%  perf-profile.children.cycles-pp.hrtimer_interrupt
      0.00            +0.2        0.19 +- 12%  perf-profile.children.cycles-pp.ktime_get
      2.42            +0.3        2.77        perf-profile.children.cycles-pp.remove_vma
     64.49            +0.5       64.94        perf-profile.children.cycles-pp.entry_SYSCALL_64_after_hwframe
      1.27            +0.5        1.73        perf-profile.children.cycles-pp.__vma_rb_erase
     61.62            +0.5       62.10        perf-profile.children.cycles-pp.__x64_sys_brk
     63.24            +0.5       63.74        perf-profile.children.cycles-pp.do_syscall_64
      4.03            +0.5        4.56        perf-profile.children.cycles-pp.vma_link
      0.00            +0.7        0.69        perf-profile.children.cycles-pp.put_vma
     25.13            +0.7       25.84        perf-profile.children.cycles-pp.do_munmap
      3.83            +0.7        4.56        perf-profile.children.cycles-pp.__vma_link_rb
      0.00            +1.2        1.25        perf-profile.children.cycles-pp.__vma_merge
      0.00            +1.5        1.53        perf-profile.children.cycles-pp._raw_write_lock
      5.08            -0.5        4.58        perf-profile.self.cycles-pp.vma_compute_subtree_gap
     15.03            -0.3       14.77        perf-profile.self.cycles-pp.syscall_return_via_sysret
      0.59            -0.2        0.39        perf-profile.self.cycles-pp.remove_vma
      0.72 +-  7%      -0.1        0.58        perf-profile.self.cycles-pp.__vm_enough_memory
      1.12            -0.1        0.99        perf-profile.self.cycles-pp.kmem_cache_free
      3.11            -0.1        2.99        perf-profile.self.cycles-pp.do_munmap
      0.99            -0.1        0.88        perf-profile.self.cycles-pp.__vma_rb_erase
      3.63            -0.1        3.52        perf-profile.self.cycles-pp.perf_event_mmap
      3.26            -0.1        3.17        perf-profile.self.cycles-pp.brk
      0.41 +-  2%      -0.1        0.33        perf-profile.self.cycles-pp.unmap_vmas
      0.74            -0.1        0.67        perf-profile.self.cycles-pp.sync_mm_rss
      1.75            -0.1        1.68        perf-profile.self.cycles-pp.kmem_cache_alloc
      0.40 +-  2%      -0.1        0.34        perf-profile.self.cycles-pp.__rb_insert_augmented
      1.29 +-  2%      -0.1        1.23        perf-profile.self.cycles-pp.__indirect_thunk_start
      0.73            -0.0        0.68 +-  2%  perf-profile.self.cycles-pp.unmap_region
      0.53            -0.0        0.49        perf-profile.self.cycles-pp.vma_link
      1.40            -0.0        1.35        perf-profile.self.cycles-pp.entry_SYSCALL_64_after_hwframe
      5.22            -0.0        5.18        perf-profile.self.cycles-pp.unmap_page_range
      0.53 +-  2%      -0.0        0.49 +-  2%  perf-profile.self.cycles-pp.cap_capable
      1.11            -0.0        1.07        perf-profile.self.cycles-pp.memcpy_erms
      1.86            -0.0        1.82        perf-profile.self.cycles-pp.perf_iterate_sb
      1.30            -0.0        1.27        perf-profile.self.cycles-pp.arch_get_unmapped_area_topdown
      0.13            -0.0        0.10        perf-profile.self.cycles-pp.__vma_link_file
      0.55            -0.0        0.52        perf-profile.self.cycles-pp.unmap_single_vma
      0.74            -0.0        0.72        perf-profile.self.cycles-pp.selinux_mmap_addr
      0.32            -0.0        0.30        perf-profile.self.cycles-pp.userfaultfd_unmap_complete
      1.13            -0.0        1.12        perf-profile.self.cycles-pp.__might_sleep
      1.24            -0.0        1.23        perf-profile.self.cycles-pp.up_write
      0.50            -0.0        0.49        perf-profile.self.cycles-pp.userfaultfd_unmap_prep
      0.27            -0.0        0.26        perf-profile.self.cycles-pp.tlb_flush_mmu_free
      0.07            -0.0        0.06        perf-profile.self.cycles-pp.should_failslab
      0.45            +0.0        0.47        perf-profile.self.cycles-pp.rcu_all_qs
      0.71            +0.0        0.73        perf-profile.self.cycles-pp.strlcpy
      0.15 +-  3%      +0.0        0.17 +-  4%  perf-profile.self.cycles-pp.__vma_link_list
      0.51            +0.1        0.57        perf-profile.self.cycles-pp.free_pgtables
      1.40            +0.1        1.49        perf-profile.self.cycles-pp.__vma_link_rb
      2.27            +0.1        2.39        perf-profile.self.cycles-pp.vmacache_find
      0.00            +0.2        0.18 +- 12%  perf-profile.self.cycles-pp.ktime_get
      0.00            +0.7        0.69        perf-profile.self.cycles-pp.put_vma
      0.00            +1.2        1.24        perf-profile.self.cycles-pp.__vma_merge
      0.00            +1.5        1.52        perf-profile.self.cycles-pp._raw_write_lock

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/always/page_fault2/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :3           33%           1:3     dmesg.WARNING:at#for_ip_native_iret/0x
          1:3          -33%            :3     dmesg.WARNING:stack_going_in_the_wrong_direction?ip=__schedule/0x
           :3           33%           1:3     dmesg.WARNING:stack_going_in_the_wrong_direction?ip=__slab_free/0x
          1:3          -33%            :3     kmsg.DHCP/BOOTP:Reply_not_for_us_on_eth#,op[#]xid[#]
          3:3         -100%            :3     kmsg.pstore:crypto_comp_decompress_failed,ret=
          3:3         -100%            :3     kmsg.pstore:decompression_failed
          2:3            4%           2:3     perf-profile.calltrace.cycles-pp.sync_regs.error_entry
          5:3            7%           5:3     perf-profile.calltrace.cycles-pp.error_entry
          5:3            7%           5:3     perf-profile.children.cycles-pp.error_entry
          2:3            3%           2:3     perf-profile.self.cycles-pp.error_entry
         %stddev     %change         %stddev
             \          |                \  
      8281 +-  2%     -18.8%       6728        will-it-scale.per_thread_ops
     92778 +-  2%     +17.6%     109080        will-it-scale.time.involuntary_context_switches
  21954366 +-  3%      +4.1%   22857988 +-  2%  will-it-scale.time.maximum_resident_set_size
  4.81e+08 +-  2%     -18.9%  3.899e+08        will-it-scale.time.minor_page_faults
      5804           +12.2%       6512        will-it-scale.time.percent_of_cpu_this_job_got
     34918           +12.2%      39193        will-it-scale.time.system_time
   5638528 +-  2%     -15.3%    4778392        will-it-scale.time.voluntary_context_switches
  15846405            -2.0%   15531034        will-it-scale.workload
   2818137            +1.5%    2861500        interrupts.CAL:Function_call_interrupts
      3.33 +- 28%     -60.0%       1.33 +- 93%  irq_exception_noise.irq_time
      2866           +23.9%       3552 +-  2%  kthread_noise.total_time
   5589674 +- 14%     +31.4%    7344810 +-  6%  meminfo.DirectMap2M
     31169           -16.9%      25906        uptime.idle
     25242 +-  4%     -14.2%      21654 +-  6%  vmstat.system.cs
      7055           -11.6%       6237        boot-time.idle
     21.12           +19.3%      25.19 +-  9%  boot-time.kernel_boot
     20.03 +-  2%      -3.7       16.38        mpstat.cpu.idle%
      0.00 +-  8%      -0.0        0.00 +-  4%  mpstat.cpu.iowait%
   7284147 +-  2%     -16.4%    6092495        softirqs.RCU
   5350756 +-  2%     -10.9%    4769417 +-  4%  softirqs.SCHED
     42933 +- 21%     -28.2%      30807 +-  7%  numa-meminfo.node2.SReclaimable
     63219 +- 13%     -16.6%      52717 +-  6%  numa-meminfo.node2.SUnreclaim
    106153 +- 16%     -21.3%      83525 +-  5%  numa-meminfo.node2.Slab
    247154 +-  4%      -7.6%     228415        numa-meminfo.node3.Unevictable
     11904 +-  4%     +17.1%      13945 +-  8%  numa-vmstat.node0
      2239 +- 22%     -26.6%       1644 +-  2%  numa-vmstat.node2.nr_mapped
     10728 +- 21%     -28.2%       7701 +-  7%  numa-vmstat.node2.nr_slab_reclaimable
     15803 +- 13%     -16.6%      13179 +-  6%  numa-vmstat.node2.nr_slab_unreclaimable
     61788 +-  4%      -7.6%      57103        numa-vmstat.node3.nr_unevictable
     61788 +-  4%      -7.6%      57103        numa-vmstat.node3.nr_zone_unevictable
     92778 +-  2%     +17.6%     109080        time.involuntary_context_switches
  21954366 +-  3%      +4.1%   22857988 +-  2%  time.maximum_resident_set_size
  4.81e+08 +-  2%     -18.9%  3.899e+08        time.minor_page_faults
      5804           +12.2%       6512        time.percent_of_cpu_this_job_got
     34918           +12.2%      39193        time.system_time
   5638528 +-  2%     -15.3%    4778392        time.voluntary_context_switches
   3942289 +-  2%     -10.5%    3528902 +-  2%  cpuidle.C1.time
    242290           -14.2%     207992        cpuidle.C1.usage
  1.64e+09 +-  2%     -15.7%  1.381e+09        cpuidle.C1E.time
   4621281 +-  2%     -14.7%    3939757        cpuidle.C1E.usage
 2.115e+10 +-  2%     -18.5%  1.723e+10        cpuidle.C6.time
  24771099 +-  2%     -18.0%   20305766        cpuidle.C6.usage
   1210810 +-  4%     -17.6%     997270 +-  2%  cpuidle.POLL.time
     18742 +-  3%     -17.0%      15559 +-  2%  cpuidle.POLL.usage
      4135 +-141%    -100.0%       0.00        latency_stats.avg.x86_reserve_hardware.x86_pmu_event_init.perf_try_init_event.perf_event_alloc.__do_sys_perf_event_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     33249 +-129%    -100.0%       0.00        latency_stats.max.call_rwsem_down_read_failed.m_start.seq_read.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4135 +-141%    -100.0%       0.00        latency_stats.max.x86_reserve_hardware.x86_pmu_event_init.perf_try_init_event.perf_event_alloc.__do_sys_perf_event_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
     65839 +-116%    -100.0%       0.00        latency_stats.sum.call_rwsem_down_read_failed.m_start.seq_read.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4135 +-141%    -100.0%       0.00        latency_stats.sum.x86_reserve_hardware.x86_pmu_event_init.perf_try_init_event.perf_event_alloc.__do_sys_perf_event_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      8387 +-122%     -90.9%     767.00 +- 13%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
    263970 +- 10%     -68.6%      82994 +-  3%  latency_stats.sum.do_syslog.kmsg_read.proc_reg_read.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      6173 +- 77%    +173.3%      16869 +- 98%  latency_stats.sum.pipe_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
    101.33            -4.6%      96.67        proc-vmstat.nr_anon_transparent_hugepages
     39967            -1.8%      39241        proc-vmstat.nr_slab_reclaimable
     67166            -2.4%      65522        proc-vmstat.nr_slab_unreclaimable
    237743            -3.9%     228396        proc-vmstat.nr_unevictable
    237743            -3.9%     228396        proc-vmstat.nr_zone_unevictable
 4.807e+09            -2.0%   4.71e+09        proc-vmstat.numa_hit
 4.807e+09            -2.0%   4.71e+09        proc-vmstat.numa_local
 4.791e+09            -2.1%   4.69e+09        proc-vmstat.pgalloc_normal
 4.783e+09            -2.0%  4.685e+09        proc-vmstat.pgfault
 4.807e+09            -2.0%  4.709e+09        proc-vmstat.pgfree
      1753            +4.6%       1833        turbostat.Avg_MHz
    239445           -14.1%     205783        turbostat.C1
   4617105 +-  2%     -14.8%    3934693        turbostat.C1E
      1.40 +-  2%      -0.2        1.18        turbostat.C1E%
  24764661 +-  2%     -18.0%   20297643        turbostat.C6
     18.09 +-  2%      -3.4       14.74        turbostat.C6%
      7.53 +-  2%     -17.1%       6.24        turbostat.CPU%c1
     11.88 +-  2%     -19.1%       9.61        turbostat.CPU%c6
      7.62 +-  3%     -20.8%       6.04        turbostat.Pkg%pc2
    388.30            +1.5%     393.93        turbostat.PkgWatt
    390974 +-  8%     +35.8%     530867 +- 11%  sched_debug.cfs_rq:/.min_vruntime.stddev
  -1754042           +75.7%   -3081270        sched_debug.cfs_rq:/.spread0.min
    388140 +-  8%     +36.2%     528494 +- 11%  sched_debug.cfs_rq:/.spread0.stddev
    542.30 +-  3%     -10.0%     488.21 +-  3%  sched_debug.cfs_rq:/.util_avg.min
     53.35 +- 16%     +48.7%      79.35 +- 12%  sched_debug.cfs_rq:/.util_est_enqueued.avg
     30520 +-  6%     -15.2%      25883 +- 12%  sched_debug.cpu.nr_switches.avg
    473770 +- 27%     -37.4%     296623 +- 32%  sched_debug.cpu.nr_switches.max
     17077 +-  2%     -15.1%      14493        sched_debug.cpu.nr_switches.min
     30138 +-  6%     -15.0%      25606 +- 12%  sched_debug.cpu.sched_count.avg
    472345 +- 27%     -37.2%     296419 +- 32%  sched_debug.cpu.sched_count.max
     16858 +-  2%     -15.2%      14299        sched_debug.cpu.sched_count.min
      8358 +-  2%     -15.5%       7063        sched_debug.cpu.sched_goidle.avg
     12225           -13.6%      10565        sched_debug.cpu.sched_goidle.max
      8032 +-  2%     -16.0%       6749        sched_debug.cpu.sched_goidle.min
     14839 +-  6%     -15.3%      12568 +- 12%  sched_debug.cpu.ttwu_count.avg
    235115 +- 28%     -38.3%     145175 +- 31%  sched_debug.cpu.ttwu_count.max
      7627 +-  3%     -15.9%       6413 +-  2%  sched_debug.cpu.ttwu_count.min
    226299 +- 29%     -39.5%     136827 +- 32%  sched_debug.cpu.ttwu_local.max
      0.85            -0.0        0.81        perf-stat.branch-miss-rate%
 3.675e+10            -4.1%  3.523e+10        perf-stat.branch-misses
 4.052e+11            -2.3%  3.958e+11        perf-stat.cache-misses
 7.008e+11            -2.5%  6.832e+11        perf-stat.cache-references
  15320995 +-  4%     -14.3%   13136557 +-  6%  perf-stat.context-switches
      9.16            +4.8%       9.59        perf-stat.cpi
  2.03e+14            +4.6%  2.124e+14        perf-stat.cpu-cycles
     44508            -1.7%      43743        perf-stat.cpu-migrations
      1.30            -0.1        1.24        perf-stat.dTLB-store-miss-rate%
 4.064e+10            -3.5%  3.922e+10        perf-stat.dTLB-store-misses
 3.086e+12            +1.1%  3.119e+12        perf-stat.dTLB-stores
 3.611e+08 +-  6%      -8.5%  3.304e+08 +-  5%  perf-stat.iTLB-loads
      0.11            -4.6%       0.10        perf-stat.ipc
 4.783e+09            -2.0%  4.685e+09        perf-stat.minor-faults
      1.53 +-  2%      -0.3        1.22 +-  8%  perf-stat.node-load-miss-rate%
 1.389e+09 +-  3%     -22.1%  1.083e+09 +-  9%  perf-stat.node-load-misses
 8.922e+10            -1.9%   8.75e+10        perf-stat.node-loads
      5.06            +1.7        6.77 +-  3%  perf-stat.node-store-miss-rate%
 1.204e+09           +29.3%  1.556e+09 +-  3%  perf-stat.node-store-misses
 2.256e+10            -5.1%  2.142e+10 +-  2%  perf-stat.node-stores
 4.783e+09            -2.0%  4.685e+09        perf-stat.page-faults
   1399242            +1.9%    1425404        perf-stat.path-length
      1144 +-  8%     -13.6%     988.00 +-  8%  slabinfo.Acpi-ParseExt.active_objs
      1144 +-  8%     -13.6%     988.00 +-  8%  slabinfo.Acpi-ParseExt.num_objs
      1878 +- 17%     +29.0%       2422 +- 16%  slabinfo.dmaengine-unmap-16.active_objs
      1878 +- 17%     +29.0%       2422 +- 16%  slabinfo.dmaengine-unmap-16.num_objs
      1085 +-  5%     -24.1%     823.33 +-  9%  slabinfo.file_lock_cache.active_objs
      1085 +-  5%     -24.1%     823.33 +-  9%  slabinfo.file_lock_cache.num_objs
     61584 +-  4%     -16.6%      51381 +-  5%  slabinfo.filp.active_objs
    967.00 +-  4%     -16.5%     807.67 +-  5%  slabinfo.filp.active_slabs
     61908 +-  4%     -16.5%      51713 +-  5%  slabinfo.filp.num_objs
    967.00 +-  4%     -16.5%     807.67 +-  5%  slabinfo.filp.num_slabs
      1455           -15.4%       1232 +-  4%  slabinfo.nsproxy.active_objs
      1455           -15.4%       1232 +-  4%  slabinfo.nsproxy.num_objs
     84720 +-  6%     -18.3%      69210 +-  4%  slabinfo.pid.active_objs
      1324 +-  6%     -18.2%       1083 +-  4%  slabinfo.pid.active_slabs
     84820 +-  5%     -18.2%      69386 +-  4%  slabinfo.pid.num_objs
      1324 +-  6%     -18.2%       1083 +-  4%  slabinfo.pid.num_slabs
      2112 +- 18%     -26.3%       1557 +-  5%  slabinfo.scsi_sense_cache.active_objs
      2112 +- 18%     -26.3%       1557 +-  5%  slabinfo.scsi_sense_cache.num_objs
      5018 +-  5%      -7.6%       4635 +-  4%  slabinfo.sock_inode_cache.active_objs
      5018 +-  5%      -7.6%       4635 +-  4%  slabinfo.sock_inode_cache.num_objs
      1193 +-  4%     +13.8%       1358 +-  4%  slabinfo.task_group.active_objs
      1193 +-  4%     +13.8%       1358 +-  4%  slabinfo.task_group.num_objs
     62807 +-  3%     -14.4%      53757 +-  3%  slabinfo.vm_area_struct.active_objs
      1571 +-  3%     -12.1%       1381 +-  3%  slabinfo.vm_area_struct.active_slabs
     62877 +-  3%     -14.3%      53880 +-  3%  slabinfo.vm_area_struct.num_objs
      1571 +-  3%     -12.1%       1381 +-  3%  slabinfo.vm_area_struct.num_slabs
     47.45           -47.4        0.00        perf-profile.calltrace.cycles-pp.alloc_pages_vma.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
     47.16           -47.2        0.00        perf-profile.calltrace.cycles-pp.__alloc_pages_nodemask.alloc_pages_vma.__handle_mm_fault.handle_mm_fault.__do_page_fault
     46.99           -47.0        0.00        perf-profile.calltrace.cycles-pp.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.__handle_mm_fault.handle_mm_fault
     44.95           -44.9        0.00        perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.__handle_mm_fault
      7.42 +-  2%      -7.4        0.00        perf-profile.calltrace.cycles-pp.copy_page.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      6.32 +- 10%      -6.3        0.00        perf-profile.calltrace.cycles-pp.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      6.28 +- 10%      -6.3        0.00        perf-profile.calltrace.cycles-pp.alloc_set_pte.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00            +0.9        0.85 +- 11%  perf-profile.calltrace.cycles-pp._raw_spin_lock.pte_map_lock.alloc_set_pte.finish_fault.handle_pte_fault
      0.00            +0.9        0.92 +-  4%  perf-profile.calltrace.cycles-pp.__list_del_entry_valid.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault
      0.00            +1.1        1.13 +-  7%  perf-profile.calltrace.cycles-pp.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault.handle_pte_fault
      0.00            +1.2        1.19 +-  7%  perf-profile.calltrace.cycles-pp.shmem_getpage_gfp.shmem_fault.__do_fault.handle_pte_fault.__handle_mm_fault
      0.00            +1.2        1.22 +-  5%  perf-profile.calltrace.cycles-pp.pte_map_lock.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault
      0.00            +1.3        1.34 +-  7%  perf-profile.calltrace.cycles-pp.shmem_fault.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +1.4        1.36 +-  7%  perf-profile.calltrace.cycles-pp.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00            +4.5        4.54 +- 19%  perf-profile.calltrace.cycles-pp.pagevec_lru_move_fn.__lru_cache_add.alloc_set_pte.finish_fault.handle_pte_fault
      0.00            +4.6        4.64 +- 19%  perf-profile.calltrace.cycles-pp.__lru_cache_add.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault
      0.00            +6.6        6.64 +- 15%  perf-profile.calltrace.cycles-pp.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +6.7        6.68 +- 15%  perf-profile.calltrace.cycles-pp.finish_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00            +7.5        7.54 +-  5%  perf-profile.calltrace.cycles-pp.copy_page.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00           +44.6       44.55 +-  3%  perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault
      0.00           +46.6       46.63 +-  3%  perf-profile.calltrace.cycles-pp.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault.__handle_mm_fault
      0.00           +46.8       46.81 +-  3%  perf-profile.calltrace.cycles-pp.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00           +47.1       47.10 +-  3%  perf-profile.calltrace.cycles-pp.alloc_pages_vma.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00           +63.1       63.15        perf-profile.calltrace.cycles-pp.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      0.39 +-  3%      +0.0        0.42 +-  3%  perf-profile.children.cycles-pp.radix_tree_lookup_slot
      0.21 +-  3%      +0.0        0.25 +-  5%  perf-profile.children.cycles-pp.__mod_node_page_state
      0.00            +0.1        0.06 +-  8%  perf-profile.children.cycles-pp.get_vma_policy
      0.00            +0.1        0.08 +-  5%  perf-profile.children.cycles-pp.__lru_cache_add_active_or_unevictable
      0.00            +0.2        0.18 +-  6%  perf-profile.children.cycles-pp.__page_add_new_anon_rmap
      0.00            +1.4        1.35 +-  5%  perf-profile.children.cycles-pp.pte_map_lock
      0.00           +63.2       63.21        perf-profile.children.cycles-pp.handle_pte_fault
      1.40 +-  2%      -0.4        1.03 +- 10%  perf-profile.self.cycles-pp._raw_spin_lock
      0.56 +-  3%      -0.2        0.35 +-  6%  perf-profile.self.cycles-pp.__handle_mm_fault
      0.22 +-  3%      -0.0        0.18 +-  7%  perf-profile.self.cycles-pp.alloc_set_pte
      0.09            +0.0        0.10 +-  4%  perf-profile.self.cycles-pp.vmacache_find
      0.39 +-  2%      +0.0        0.41 +-  3%  perf-profile.self.cycles-pp.__radix_tree_lookup
      0.18            +0.0        0.20 +-  6%  perf-profile.self.cycles-pp.mem_cgroup_charge_statistics
      0.17 +-  2%      +0.0        0.20 +-  7%  perf-profile.self.cycles-pp.___might_sleep
      0.33 +-  2%      +0.0        0.36 +-  6%  perf-profile.self.cycles-pp.handle_mm_fault
      0.20 +-  2%      +0.0        0.24 +-  3%  perf-profile.self.cycles-pp.__mod_node_page_state
      0.00            +0.1        0.05        perf-profile.self.cycles-pp.finish_fault
      0.00            +0.1        0.05        perf-profile.self.cycles-pp.get_vma_policy
      0.00            +0.1        0.08 +- 10%  perf-profile.self.cycles-pp.__lru_cache_add_active_or_unevictable
      0.00            +0.2        0.25 +-  5%  perf-profile.self.cycles-pp.handle_pte_fault
      0.00            +0.5        0.49 +-  8%  perf-profile.self.cycles-pp.pte_map_lock

=========================================================================================
tbox_group/testcase/rootfs/kconfig/compiler/nr_task/thp_enabled/test/cpufreq_governor:
  lkp-skl-4sp1/will-it-scale/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/100%/never/page_fault2/performance

commit: 
  ba98a1cdad71d259a194461b3a61471b49b14df1
  a7a8993bfe3ccb54ad468b9f1799649e4ad1ff12

ba98a1cdad71d259 a7a8993bfe3ccb54ad468b9f17 
---------------- -------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
          1:3          -33%            :3     kmsg.DHCP/BOOTP:Reply_not_for_us_on_eth#,op[#]xid[#]
           :3           33%           1:3     dmesg.WARNING:stack_going_in_the_wrong_direction?ip=sched_slice/0x
          1:3          -33%            :3     dmesg.WARNING:stack_going_in_the_wrong_direction?ip=schedule_tail/0x
          1:3           24%           2:3     perf-profile.calltrace.cycles-pp.sync_regs.error_entry
          3:3           46%           5:3     perf-profile.calltrace.cycles-pp.error_entry
          5:3           -9%           5:3     perf-profile.children.cycles-pp.error_entry
          2:3           -4%           2:3     perf-profile.self.cycles-pp.error_entry
         %stddev     %change         %stddev
             \          |                \  
      8147           -18.8%       6613        will-it-scale.per_thread_ops
     93113           +17.0%     108982        will-it-scale.time.involuntary_context_switches
 4.732e+08           -19.0%  3.833e+08        will-it-scale.time.minor_page_faults
      5854           +12.0%       6555        will-it-scale.time.percent_of_cpu_this_job_got
     35247           +12.1%      39495        will-it-scale.time.system_time
   5546661           -15.5%    4689314        will-it-scale.time.voluntary_context_switches
  15801637            -1.9%   15504487        will-it-scale.workload
      1.43 +- 11%     -59.7%       0.58 +- 28%  irq_exception_noise.__do_page_fault.min
      2811 +-  3%     +23.7%       3477 +-  3%  kthread_noise.total_time
    292776 +-  5%     +39.6%     408829 +- 21%  meminfo.DirectMap4k
     19.80            -3.7       16.12        mpstat.cpu.idle%
     29940           -14.5%      25593        uptime.idle
     24064 +-  3%      -8.5%      22016        vmstat.system.cs
     34.86            -1.9%      34.19        boot-time.boot
     26.95            -2.8%      26.19 +-  2%  boot-time.kernel_boot
   7190569 +-  2%     -15.2%    6100136 +-  3%  softirqs.RCU
   5513663           -13.8%    4751548        softirqs.SCHED
     18064 +-  2%     +24.3%      22461 +-  7%  numa-vmstat.node0.nr_slab_unreclaimable
      8507 +- 12%     -16.8%       7075 +-  4%  numa-vmstat.node2.nr_slab_reclaimable
     18719 +-  9%     -19.6%      15043 +-  4%  numa-vmstat.node3.nr_slab_unreclaimable
     72265 +-  2%     +24.3%      89855 +-  7%  numa-meminfo.node0.SUnreclaim
    115980 +-  4%     +22.6%     142233 +- 12%  numa-meminfo.node0.Slab
     34035 +- 12%     -16.8%      28307 +-  4%  numa-meminfo.node2.SReclaimable
     74888 +-  9%     -19.7%      60162 +-  4%  numa-meminfo.node3.SUnreclaim
     93113           +17.0%     108982        time.involuntary_context_switches
 4.732e+08           -19.0%  3.833e+08        time.minor_page_faults
      5854           +12.0%       6555        time.percent_of_cpu_this_job_got
     35247           +12.1%      39495        time.system_time
   5546661           -15.5%    4689314        time.voluntary_context_switches
 4.792e+09            -1.9%  4.699e+09        proc-vmstat.numa_hit
 4.791e+09            -1.9%  4.699e+09        proc-vmstat.numa_local
     40447 +- 11%     +13.2%      45804 +-  6%  proc-vmstat.pgactivate
 4.778e+09            -1.9%  4.688e+09        proc-vmstat.pgalloc_normal
 4.767e+09            -1.9%  4.675e+09        proc-vmstat.pgfault
 4.791e+09            -1.9%  4.699e+09        proc-vmstat.pgfree
    230178 +-  2%     -10.1%     206883 +-  3%  cpuidle.C1.usage
 1.617e+09           -15.0%  1.375e+09        cpuidle.C1E.time
   4514401           -14.1%    3878206        cpuidle.C1E.usage
 2.087e+10           -18.5%  1.701e+10        cpuidle.C6.time
  24458365           -18.0%   20045336        cpuidle.C6.usage
   1163758           -16.1%     976094 +-  4%  cpuidle.POLL.time
     17907           -14.6%      15294 +-  4%  cpuidle.POLL.usage
      1758            +4.5%       1838        turbostat.Avg_MHz
    227522 +-  2%     -10.2%     204426 +-  3%  turbostat.C1
   4512700           -14.2%    3873264        turbostat.C1E
      1.39            -0.2        1.18        turbostat.C1E%
  24452583           -18.0%   20039031        turbostat.C6
     17.85            -3.3       14.55        turbostat.C6%
      7.44           -16.8%       6.19        turbostat.CPU%c1
     11.72           -19.3%       9.45        turbostat.CPU%c6
      7.51           -21.3%       5.91        turbostat.Pkg%pc2
    389.33            +1.6%     395.59        turbostat.PkgWatt
    559.33 +- 13%     -17.9%     459.33 +- 20%  slabinfo.dmaengine-unmap-128.active_objs
    559.33 +- 13%     -17.9%     459.33 +- 20%  slabinfo.dmaengine-unmap-128.num_objs
     57734 +-  3%      -5.7%      54421 +-  4%  slabinfo.filp.active_objs
    905.67 +-  3%      -5.6%     854.67 +-  4%  slabinfo.filp.active_slabs
     57981 +-  3%      -5.6%      54720 +-  4%  slabinfo.filp.num_objs
    905.67 +-  3%      -5.6%     854.67 +-  4%  slabinfo.filp.num_slabs
      1378           -12.0%       1212 +-  7%  slabinfo.nsproxy.active_objs
      1378           -12.0%       1212 +-  7%  slabinfo.nsproxy.num_objs
    507.33 +-  7%     -26.8%     371.33 +-  2%  slabinfo.secpath_cache.active_objs
    507.33 +-  7%     -26.8%     371.33 +-  2%  slabinfo.secpath_cache.num_objs
      4788 +-  5%      -8.3%       4391 +-  2%  slabinfo.sock_inode_cache.active_objs
      4788 +-  5%      -8.3%       4391 +-  2%  slabinfo.sock_inode_cache.num_objs
      1431 +-  8%     -12.3%       1255 +-  3%  slabinfo.task_group.active_objs
      1431 +-  8%     -12.3%       1255 +-  3%  slabinfo.task_group.num_objs
      4.27 +- 17%     +27.0%       5.42 +-  7%  sched_debug.cfs_rq:/.runnable_load_avg.avg
     13.44 +- 62%     +73.6%      23.33 +- 24%  sched_debug.cfs_rq:/.runnable_load_avg.stddev
    772.55 +- 21%     -32.7%     520.27 +-  4%  sched_debug.cfs_rq:/.util_est_enqueued.max
      4.39 +- 15%     +29.0%       5.66 +- 11%  sched_debug.cpu.cpu_load[0].avg
    152.09 +- 72%     +83.9%     279.67 +- 33%  sched_debug.cpu.cpu_load[0].max
     13.84 +- 58%     +78.7%      24.72 +- 29%  sched_debug.cpu.cpu_load[0].stddev
      4.53 +- 14%     +25.8%       5.70 +- 10%  sched_debug.cpu.cpu_load[1].avg
    156.58 +- 66%     +76.6%     276.58 +- 33%  sched_debug.cpu.cpu_load[1].max
     14.02 +- 55%     +72.4%      24.17 +- 28%  sched_debug.cpu.cpu_load[1].stddev
      4.87 +- 11%     +17.3%       5.72 +-  9%  sched_debug.cpu.cpu_load[2].avg
      1.58 +-  2%     +13.5%       1.79 +-  6%  sched_debug.cpu.nr_running.max
     16694           -14.6%      14259        sched_debug.cpu.nr_switches.min
     31989 +- 13%     +20.6%      38584 +-  6%  sched_debug.cpu.nr_switches.stddev
     16505           -14.8%      14068        sched_debug.cpu.sched_count.min
     32084 +- 13%     +19.9%      38482 +-  6%  sched_debug.cpu.sched_count.stddev
      8185           -15.0%       6957        sched_debug.cpu.sched_goidle.avg
     12151 +-  2%     -13.5%      10507        sched_debug.cpu.sched_goidle.max
      7867           -15.7%       6631        sched_debug.cpu.sched_goidle.min
      7595           -16.1%       6375        sched_debug.cpu.ttwu_count.min
     15873 +- 13%     +21.2%      19239 +-  6%  sched_debug.cpu.ttwu_count.stddev
      5244 +- 17%     +17.0%       6134 +-  5%  sched_debug.cpu.ttwu_local.avg
     15646 +- 12%     +21.5%      19008 +-  6%  sched_debug.cpu.ttwu_local.stddev
      0.85            -0.0        0.81        perf-stat.branch-miss-rate%
 3.689e+10            -4.6%  3.518e+10        perf-stat.branch-misses
     57.39            +0.6       58.00        perf-stat.cache-miss-rate%
 4.014e+11            -1.2%  3.967e+11        perf-stat.cache-misses
 6.994e+11            -2.2%   6.84e+11        perf-stat.cache-references
  14605393 +-  3%      -8.5%   13369913        perf-stat.context-switches
      9.21            +4.5%       9.63        perf-stat.cpi
 2.037e+14            +4.6%   2.13e+14        perf-stat.cpu-cycles
     44424            -2.0%      43541        perf-stat.cpu-migrations
      1.29            -0.1        1.24        perf-stat.dTLB-store-miss-rate%
 4.018e+10            -2.8%  3.905e+10        perf-stat.dTLB-store-misses
 3.071e+12            +1.4%  3.113e+12        perf-stat.dTLB-stores
     93.04            +1.5       94.51        perf-stat.iTLB-load-miss-rate%
 4.946e+09           +19.3%  5.903e+09 +-  5%  perf-stat.iTLB-load-misses
 3.702e+08            -7.5%  3.423e+08 +-  2%  perf-stat.iTLB-loads
      4470           -15.9%       3760 +-  5%  perf-stat.instructions-per-iTLB-miss
      0.11            -4.3%       0.10        perf-stat.ipc
 4.767e+09            -1.9%  4.675e+09        perf-stat.minor-faults
      1.46 +-  4%      -0.1        1.33 +-  9%  perf-stat.node-load-miss-rate%
      4.91            +1.7        6.65 +-  2%  perf-stat.node-store-miss-rate%
 1.195e+09           +32.8%  1.587e+09 +-  2%  perf-stat.node-store-misses
 2.313e+10            -3.7%  2.227e+10        perf-stat.node-stores
 4.767e+09            -1.9%  4.675e+09        perf-stat.page-faults
   1399047            +2.0%    1427115        perf-stat.path-length
      8908 +- 73%    -100.0%       0.00        latency_stats.avg.call_rwsem_down_read_failed.m_start.seq_read.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      3604 +-141%    -100.0%       0.00        latency_stats.avg.call_rwsem_down_write_failed.do_unlinkat.do_syscall_64.entry_SYSCALL_64_after_hwframe
     61499 +-130%     -92.6%       4534 +- 16%  latency_stats.avg.expand_files.__alloc_fd.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4391 +-138%     -70.9%       1277 +-129%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
     67311 +-112%     -48.5%      34681 +- 36%  latency_stats.avg.max
      3956 +-138%    +320.4%      16635 +-140%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
    164.67 +- 30%   +7264.0%      12126 +-138%  latency_stats.avg.flush_work.fsnotify_destroy_group.inotify_release.__fput.task_work_run.exit_to_usermode_loop.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +5.4e+105%       5367 +-141%  latency_stats.avg.call_rwsem_down_write_failed.unlink_file_vma.free_pgtables.exit_mmap.mmput.flush_old_exec.load_elf_binary.search_binary_handler.do_execveat_common.__x64_sys_execve.do_syscall_64.entry_SYSCALL_64_after_hwframe
     36937 +-119%    -100.0%       0.00        latency_stats.max.call_rwsem_down_read_failed.m_start.seq_read.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      3604 +-141%    -100.0%       0.00        latency_stats.max.call_rwsem_down_write_failed.do_unlinkat.do_syscall_64.entry_SYSCALL_64_after_hwframe
     84146 +-107%     -72.5%      23171 +- 31%  latency_stats.max.expand_files.__alloc_fd.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4391 +-138%     -70.9%       1277 +-129%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
      5817 +- 83%     -69.7%       1760 +- 67%  latency_stats.max.pipe_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      6720 +-137%   +1628.2%     116147 +-141%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
    164.67 +- 30%   +7264.0%      12126 +-138%  latency_stats.max.flush_work.fsnotify_destroy_group.inotify_release.__fput.task_work_run.exit_to_usermode_loop.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +1.2e+106%      12153 +-141%  latency_stats.max.call_rwsem_down_write_failed.unlink_file_vma.free_pgtables.exit_mmap.mmput.flush_old_exec.load_elf_binary.search_binary_handler.do_execveat_common.__x64_sys_execve.do_syscall_64.entry_SYSCALL_64_after_hwframe
    110122 +-120%    -100.0%       0.00        latency_stats.sum.call_rwsem_down_read_failed.m_start.seq_read.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      3604 +-141%    -100.0%       0.00        latency_stats.sum.call_rwsem_down_write_failed.do_unlinkat.do_syscall_64.entry_SYSCALL_64_after_hwframe
  12078828 +-139%     -99.3%      89363 +- 29%  latency_stats.sum.expand_files.__alloc_fd.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
    144453 +-120%     -80.9%      27650 +- 19%  latency_stats.sum.poll_schedule_timeout.do_sys_poll.__x64_sys_poll.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4391 +-138%     -70.9%       1277 +-129%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup_revalidate.lookup_fast.walk_component.link_path_walk.path_lookupat.filename_lookup
      9438 +- 86%     -68.4%       2980 +- 35%  latency_stats.sum.pipe_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
     31656 +-138%    +320.4%     133084 +-140%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
    164.67 +- 30%   +7264.0%      12126 +-138%  latency_stats.sum.flush_work.fsnotify_destroy_group.inotify_release.__fput.task_work_run.exit_to_usermode_loop.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +8.8e+105%       8760 +-141%  latency_stats.sum.msleep_interruptible.uart_wait_until_sent.tty_wait_until_sent.tty_port_close_start.tty_port_close.tty_release.__fput.task_work_run.exit_to_usermode_loop.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +1.3e+106%      12897 +-141%  latency_stats.sum.tty_wait_until_sent.tty_port_close_start.tty_port_close.tty_release.__fput.task_work_run.exit_to_usermode_loop.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00       +3.2e+106%      32207 +-141%  latency_stats.sum.call_rwsem_down_write_failed.unlink_file_vma.free_pgtables.exit_mmap.mmput.flush_old_exec.load_elf_binary.search_binary_handler.do_execveat_common.__x64_sys_execve.do_syscall_64.entry_SYSCALL_64_after_hwframe
     44.43 +-  3%     -44.4        0.00        perf-profile.calltrace.cycles-pp.alloc_pages_vma.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
     44.13 +-  3%     -44.1        0.00        perf-profile.calltrace.cycles-pp.__alloc_pages_nodemask.alloc_pages_vma.__handle_mm_fault.handle_mm_fault.__do_page_fault
     43.95 +-  3%     -43.9        0.00        perf-profile.calltrace.cycles-pp.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.__handle_mm_fault.handle_mm_fault
     41.85 +-  4%     -41.9        0.00        perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.__handle_mm_fault
      7.74 +-  8%      -7.7        0.00        perf-profile.calltrace.cycles-pp.copy_page.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      7.19 +-  4%      -7.2        0.00        perf-profile.calltrace.cycles-pp.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      7.15 +-  4%      -7.2        0.00        perf-profile.calltrace.cycles-pp.alloc_set_pte.finish_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      5.09 +-  3%      -5.1        0.00        perf-profile.calltrace.cycles-pp.__lru_cache_add.alloc_set_pte.finish_fault.__handle_mm_fault.handle_mm_fault
      4.99 +-  3%      -5.0        0.00        perf-profile.calltrace.cycles-pp.pagevec_lru_move_fn.__lru_cache_add.alloc_set_pte.finish_fault.__handle_mm_fault
      0.93 +-  6%      -0.1        0.81 +-  2%  perf-profile.calltrace.cycles-pp.find_get_entry.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault
      0.00            +0.8        0.84        perf-profile.calltrace.cycles-pp._raw_spin_lock.pte_map_lock.alloc_set_pte.finish_fault.handle_pte_fault
      0.00            +0.9        0.92 +-  3%  perf-profile.calltrace.cycles-pp.__list_del_entry_valid.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault
      0.00            +1.1        1.08        perf-profile.calltrace.cycles-pp.find_lock_entry.shmem_getpage_gfp.shmem_fault.__do_fault.handle_pte_fault
      0.00            +1.1        1.14        perf-profile.calltrace.cycles-pp.shmem_getpage_gfp.shmem_fault.__do_fault.handle_pte_fault.__handle_mm_fault
      0.00            +1.2        1.17        perf-profile.calltrace.cycles-pp.pte_map_lock.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault
      0.00            +1.3        1.29        perf-profile.calltrace.cycles-pp.shmem_fault.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +1.3        1.31        perf-profile.calltrace.cycles-pp.__do_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
     61.62            +1.7       63.33        perf-profile.calltrace.cycles-pp.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault.page_fault
     41.73 +-  4%      +3.0       44.75        perf-profile.calltrace.cycles-pp.native_queued_spin_lock_slowpath._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma
      0.00            +4.6        4.55 +- 15%  perf-profile.calltrace.cycles-pp.pagevec_lru_move_fn.__lru_cache_add.alloc_set_pte.finish_fault.handle_pte_fault
      0.00            +4.6        4.65 +- 14%  perf-profile.calltrace.cycles-pp.__lru_cache_add.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault
      0.00            +6.6        6.57 +- 10%  perf-profile.calltrace.cycles-pp.alloc_set_pte.finish_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00            +6.6        6.61 +- 10%  perf-profile.calltrace.cycles-pp.finish_fault.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00            +7.2        7.25 +-  2%  perf-profile.calltrace.cycles-pp.copy_page.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
     41.41 +- 70%     +22.3       63.67        perf-profile.calltrace.cycles-pp.handle_mm_fault.__do_page_fault.do_page_fault.page_fault
     42.19 +- 70%     +22.6       64.75        perf-profile.calltrace.cycles-pp.__do_page_fault.do_page_fault.page_fault
     42.20 +- 70%     +22.6       64.76        perf-profile.calltrace.cycles-pp.do_page_fault.page_fault
     42.27 +- 70%     +22.6       64.86        perf-profile.calltrace.cycles-pp.page_fault
      0.00           +44.9       44.88        perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault
      0.00           +46.9       46.92        perf-profile.calltrace.cycles-pp.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault.__handle_mm_fault
      0.00           +47.1       47.10        perf-profile.calltrace.cycles-pp.__alloc_pages_nodemask.alloc_pages_vma.handle_pte_fault.__handle_mm_fault.handle_mm_fault
      0.00           +47.4       47.37        perf-profile.calltrace.cycles-pp.alloc_pages_vma.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault
      0.00           +63.0       63.00        perf-profile.calltrace.cycles-pp.handle_pte_fault.__handle_mm_fault.handle_mm_fault.__do_page_fault.do_page_fault
      0.97 +-  6%      -0.1        0.84 +-  2%  perf-profile.children.cycles-pp.find_get_entry
      1.23 +-  6%      -0.1        1.11        perf-profile.children.cycles-pp.find_lock_entry
      0.09 +- 10%      -0.0        0.07 +-  6%  perf-profile.children.cycles-pp.unlock_page
      0.19 +-  4%      +0.0        0.21 +-  2%  perf-profile.children.cycles-pp.mem_cgroup_charge_statistics
      0.21 +-  2%      +0.0        0.25        perf-profile.children.cycles-pp.__mod_node_page_state
      0.00            +0.1        0.05 +-  8%  perf-profile.children.cycles-pp.get_vma_policy
      0.00            +0.1        0.08        perf-profile.children.cycles-pp.__lru_cache_add_active_or_unevictable
      0.00            +0.2        0.18 +-  2%  perf-profile.children.cycles-pp.__page_add_new_anon_rmap
      0.00            +1.3        1.30        perf-profile.children.cycles-pp.pte_map_lock
     63.40            +1.6       64.97        perf-profile.children.cycles-pp.__do_page_fault
     63.19            +1.6       64.83        perf-profile.children.cycles-pp.do_page_fault
     61.69            +1.7       63.36        perf-profile.children.cycles-pp.__handle_mm_fault
     63.19            +1.7       64.86        perf-profile.children.cycles-pp.page_fault
     61.99            +1.7       63.70        perf-profile.children.cycles-pp.handle_mm_fault
     72.27            +2.2       74.52        perf-profile.children.cycles-pp.native_queued_spin_lock_slowpath
     67.51            +2.4       69.87        perf-profile.children.cycles-pp._raw_spin_lock
     44.49 +-  3%      +3.0       47.45        perf-profile.children.cycles-pp.alloc_pages_vma
     44.28 +-  3%      +3.0       47.26        perf-profile.children.cycles-pp.__alloc_pages_nodemask
     44.13 +-  3%      +3.0       47.12        perf-profile.children.cycles-pp.get_page_from_freelist
      0.00           +63.1       63.06        perf-profile.children.cycles-pp.handle_pte_fault
      1.46 +-  7%      -0.5        1.01        perf-profile.self.cycles-pp._raw_spin_lock
      0.58 +-  6%      -0.2        0.34        perf-profile.self.cycles-pp.__handle_mm_fault
      0.55 +-  6%      -0.1        0.44 +-  2%  perf-profile.self.cycles-pp.find_get_entry
      0.22 +-  5%      -0.1        0.16 +-  2%  perf-profile.self.cycles-pp.alloc_set_pte
      0.10 +-  8%      -0.0        0.08        perf-profile.self.cycles-pp.down_read_trylock
      0.09 +-  5%      -0.0        0.07        perf-profile.self.cycles-pp.unlock_page
      0.06            -0.0        0.05        perf-profile.self.cycles-pp.pmd_devmap_trans_unstable
      0.20 +-  2%      +0.0        0.24 +-  3%  perf-profile.self.cycles-pp.__mod_node_page_state
      0.00            +0.1        0.05        perf-profile.self.cycles-pp.finish_fault
      0.00            +0.1        0.05        perf-profile.self.cycles-pp.get_vma_policy
      0.00            +0.1        0.08 +-  6%  perf-profile.self.cycles-pp.__lru_cache_add_active_or_unevictable
      0.00            +0.2        0.25        perf-profile.self.cycles-pp.handle_pte_fault
      0.00            +0.5        0.46 +-  7%  perf-profile.self.cycles-pp.pte_map_lock
     72.26            +2.3       74.52        perf-profile.self.cycles-pp.native_queued_spin_lock_slowpath

--eh3qi5staxrvatcj
Content-Type: application/zip
Content-Disposition: attachment; filename="perf-profile.zip"
Content-Transfer-Encoding: base64

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
cGFnZV9mYXVsdDItdjExLWRpc2FibGUtVEhQLXBlcmYtcHJvZmlsZS5qc29uVVQFAAMdsChb
dXgLAAEE6AMAAAToAwAAUEsBAh4DFAAAAAgAy3rTTF1Jpw71BwAA6UMAACwAGAAAAAAAAQAA
AKSBdRoAAHBhZ2VfZmF1bHQyLXYxMS1lbmFibGUtVEhQLXBlcmYtcHJvZmlsZS5qc29uVVQF
AAMtryhbdXgLAAEE6AMAAAToAwAAUEsBAh4DFAAAAAgAJH3TTMc20hZNCAAAbEQAAC4AGAAA
AAAAAQAAAKSB0CIAAHBhZ2VfZmF1bHQzLWJhc2UtZGlzYWJsZS1USFAtcGVyZi1wcm9maWxl
Lmpzb25VVAUAA5SzKFt1eAsAAQToAwAABOgDAABQSwECHgMUAAAACADIfNNM4P+TcZEIAAC+
RwAALQAYAAAAAAABAAAApIGFKwAAcGFnZV9mYXVsdDMtYmFzZS1lbmFibGUtVEhQLXBlcmYt
cHJvZmlsZS5qc29uVVQFAAPnsihbdXgLAAEE6AMAAAToAwAAUEsBAh4DFAAAAAgAaHvTTBxw
UvKMCAAAu0YAAC0AGAAAAAAAAQAAAKSBfTQAAHBhZ2VfZmF1bHQzLXYxMS1kaXNhYmxlLVRI
UC1wZXJmLXByb2ZpbGUuanNvblVUBQADU7AoW3V4CwABBOgDAAAE6AMAAFBLAQIeAxQAAAAI
AIR700xz5EcIzQgAAJJJAAAsABgAAAAAAAEAAACkgXA9AABwYWdlX2ZhdWx0My12MTEtZW5h
YmxlLVRIUC1wZXJmLXByb2ZpbGUuanNvblVUBQADh7AoW3V4CwABBOgDAAAE6AMAAFBLBQYA
AAAACAAIAJgDAACjRgAAAAA=

--eh3qi5staxrvatcj--
