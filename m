Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23FB56B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 04:55:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t195-v6so8141237wmt.9
        for <linux-mm@kvack.org>; Mon, 28 May 2018 01:55:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a12-v6si884712eda.443.2018.05.28.01.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 01:55:14 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4S8sOxH024078
	for <linux-mm@kvack.org>; Mon, 28 May 2018 04:55:13 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j8d85kpck-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 May 2018 04:55:12 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 28 May 2018 09:55:09 +0100
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <9FE19350E8A7EE45B64D8D63D368C8966B834B67@SHSMSX101.ccr.corp.intel.com>
 <1327633f-8bb9-99f7-fab4-4cfcbf997200@linux.vnet.ibm.com>
 <20180528082235.e5x4oiaaf7cjoddr@haiyan.lkp.sh.intel.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 28 May 2018 10:54:56 +0200
MIME-Version: 1.0
In-Reply-To: <20180528082235.e5x4oiaaf7cjoddr@haiyan.lkp.sh.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <316c6936-203d-67e9-c18c-6cf10d0d4bee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haiyan Song <haiyanx.song@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "kirill@shutemov.name" <kirill@shutemov.name>, "ak@linux.intel.com" <ak@linux.intel.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "jack@suse.cz" <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "paulus@samba.org" <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "sergey.senozhatsky.work@gmail.com" <sergey.senozhatsky.work@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, "Wang, Kemi" <kemi.wang@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "haren@linux.vnet.ibm.com" <haren@linux.vnet.ibm.com>, "npiggin@gmail.com" <npiggin@gmail.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "x86@kernel.org" <x86@kernel.org>

On 28/05/2018 10:22, Haiyan Song wrote:
> Hi Laurent,
> 
> Yes, these tests are done on V9 patch.

Do you plan to give this V11 a run ?

> 
> 
> Best regards,
> Haiyan Song
> 
> On Mon, May 28, 2018 at 09:51:34AM +0200, Laurent Dufour wrote:
>> On 28/05/2018 07:23, Song, HaiyanX wrote:
>>>
>>> Some regression and improvements is found by LKP-tools(linux kernel performance) on V9 patch series
>>> tested on Intel 4s Skylake platform.
>>
>> Hi,
>>
>> Thanks for reporting this benchmark results, but you mentioned the "V9 patch
>> series" while responding to the v11 header series...
>> Were these tests done on v9 or v11 ?
>>
>> Cheers,
>> Laurent.
>>
>>>
>>> The regression result is sorted by the metric will-it-scale.per_thread_ops.
>>> Branch: Laurent-Dufour/Speculative-page-faults/20180316-151833 (V9 patch series)
>>> Commit id:
>>>     base commit: d55f34411b1b126429a823d06c3124c16283231f
>>>     head commit: 0355322b3577eeab7669066df42c550a56801110
>>> Benchmark suite: will-it-scale
>>> Download link:
>>> https://github.com/antonblanchard/will-it-scale/tree/master/tests
>>> Metrics:
>>>     will-it-scale.per_process_ops=processes/nr_cpu
>>>     will-it-scale.per_thread_ops=threads/nr_cpu
>>> test box: lkp-skl-4sp1(nr_cpu=192,memory=768G)
>>> THP: enable / disable
>>> nr_task: 100%
>>>
>>> 1. Regressions:
>>> a) THP enabled:
>>> testcase                        base            change          head       metric
>>> page_fault3/ enable THP         10092           -17.5%          8323       will-it-scale.per_thread_ops
>>> page_fault2/ enable THP          8300           -17.2%          6869       will-it-scale.per_thread_ops
>>> brk1/ enable THP                  957.67         -7.6%           885       will-it-scale.per_thread_ops
>>> page_fault3/ enable THP        172821            -5.3%        163692       will-it-scale.per_process_ops
>>> signal1/ enable THP              9125            -3.2%          8834       will-it-scale.per_process_ops
>>>
>>> b) THP disabled:
>>> testcase                        base            change          head       metric
>>> page_fault3/ disable THP        10107           -19.1%          8180       will-it-scale.per_thread_ops
>>> page_fault2/ disable THP         8432           -17.8%          6931       will-it-scale.per_thread_ops
>>> context_switch1/ disable THP   215389            -6.8%        200776       will-it-scale.per_thread_ops
>>> brk1/ disable THP                 939.67         -6.6%           877.33    will-it-scale.per_thread_ops
>>> page_fault3/ disable THP       173145            -4.7%        165064       will-it-scale.per_process_ops
>>> signal1/ disable THP             9162            -3.9%          8802       will-it-scale.per_process_ops
>>>
>>> 2. Improvements:
>>> a) THP enabled:
>>> testcase                        base            change          head       metric
>>> malloc1/ enable THP               66.33        +469.8%           383.67    will-it-scale.per_thread_ops
>>> writeseek3/ enable THP          2531             +4.5%          2646       will-it-scale.per_thread_ops
>>> signal1/ enable THP              989.33          +2.8%          1016       will-it-scale.per_thread_ops
>>>
>>> b) THP disabled:
>>> testcase                        base            change          head       metric
>>> malloc1/ disable THP              90.33        +417.3%           467.33    will-it-scale.per_thread_ops
>>> read2/ disable THP             58934            +39.2%         82060       will-it-scale.per_thread_ops
>>> page_fault1/ disable THP        8607            +36.4%         11736       will-it-scale.per_thread_ops
>>> read1/ disable THP            314063            +12.7%        353934       will-it-scale.per_thread_ops
>>> writeseek3/ disable THP         2452            +12.5%          2759       will-it-scale.per_thread_ops
>>> signal1/ disable THP             971.33          +5.5%          1024       will-it-scale.per_thread_ops
>>>
>>> Notes: for above values in column "change", the higher value means that the related testcase result
>>> on head commit is better than that on base commit for this benchmark.
>>>
>>>
>>> Best regards
>>> Haiyan Song
>>>
>>> ________________________________________
>>> From: owner-linux-mm@kvack.org [owner-linux-mm@kvack.org] on behalf of Laurent Dufour [ldufour@linux.vnet.ibm.com]
>>> Sent: Thursday, May 17, 2018 7:06 PM
>>> To: akpm@linux-foundation.org; mhocko@kernel.org; peterz@infradead.org; kirill@shutemov.name; ak@linux.intel.com; dave@stgolabs.net; jack@suse.cz; Matthew Wilcox; khandual@linux.vnet.ibm.com; aneesh.kumar@linux.vnet.ibm.com; benh@kernel.crashing.org; mpe@ellerman.id.au; paulus@samba.org; Thomas Gleixner; Ingo Molnar; hpa@zytor.com; Will Deacon; Sergey Senozhatsky; sergey.senozhatsky.work@gmail.com; Andrea Arcangeli; Alexei Starovoitov; Wang, Kemi; Daniel Jordan; David Rientjes; Jerome Glisse; Ganesh Mahendran; Minchan Kim; Punit Agrawal; vinayak menon; Yang Shi
>>> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; haren@linux.vnet.ibm.com; npiggin@gmail.com; bsingharora@gmail.com; paulmck@linux.vnet.ibm.com; Tim Chen; linuxppc-dev@lists.ozlabs.org; x86@kernel.org
>>> Subject: [PATCH v11 00/26] Speculative page faults
>>>
>>> This is a port on kernel 4.17 of the work done by Peter Zijlstra to handle
>>> page fault without holding the mm semaphore [1].
>>>
>>> The idea is to try to handle user space page faults without holding the
>>> mmap_sem. This should allow better concurrency for massively threaded
>>> process since the page fault handler will not wait for other threads memory
>>> layout change to be done, assuming that this change is done in another part
>>> of the process's memory space. This type page fault is named speculative
>>> page fault. If the speculative page fault fails because of a concurrency is
>>> detected or because underlying PMD or PTE tables are not yet allocating, it
>>> is failing its processing and a classic page fault is then tried.
>>>
>>> The speculative page fault (SPF) has to look for the VMA matching the fault
>>> address without holding the mmap_sem, this is done by introducing a rwlock
>>> which protects the access to the mm_rb tree. Previously this was done using
>>> SRCU but it was introducing a lot of scheduling to process the VMA's
>>> freeing operation which was hitting the performance by 20% as reported by
>>> Kemi Wang [2]. Using a rwlock to protect access to the mm_rb tree is
>>> limiting the locking contention to these operations which are expected to
>>> be in a O(log n) order. In addition to ensure that the VMA is not freed in
>>> our back a reference count is added and 2 services (get_vma() and
>>> put_vma()) are introduced to handle the reference count. Once a VMA is
>>> fetched from the RB tree using get_vma(), it must be later freed using
>>> put_vma(). I can't see anymore the overhead I got while will-it-scale
>>> benchmark anymore.
>>>
>>> The VMA's attributes checked during the speculative page fault processing
>>> have to be protected against parallel changes. This is done by using a per
>>> VMA sequence lock. This sequence lock allows the speculative page fault
>>> handler to fast check for parallel changes in progress and to abort the
>>> speculative page fault in that case.
>>>
>>> Once the VMA has been found, the speculative page fault handler would check
>>> for the VMA's attributes to verify that the page fault has to be handled
>>> correctly or not. Thus, the VMA is protected through a sequence lock which
>>> allows fast detection of concurrent VMA changes. If such a change is
>>> detected, the speculative page fault is aborted and a *classic* page fault
>>> is tried.  VMA sequence lockings are added when VMA attributes which are
>>> checked during the page fault are modified.
>>>
>>> When the PTE is fetched, the VMA is checked to see if it has been changed,
>>> so once the page table is locked, the VMA is valid, so any other changes
>>> leading to touching this PTE will need to lock the page table, so no
>>> parallel change is possible at this time.
>>>
>>> The locking of the PTE is done with interrupts disabled, this allows
>>> checking for the PMD to ensure that there is not an ongoing collapsing
>>> operation. Since khugepaged is firstly set the PMD to pmd_none and then is
>>> waiting for the other CPU to have caught the IPI interrupt, if the pmd is
>>> valid at the time the PTE is locked, we have the guarantee that the
>>> collapsing operation will have to wait on the PTE lock to move forward.
>>> This allows the SPF handler to map the PTE safely. If the PMD value is
>>> different from the one recorded at the beginning of the SPF operation, the
>>> classic page fault handler will be called to handle the operation while
>>> holding the mmap_sem. As the PTE lock is done with the interrupts disabled,
>>> the lock is done using spin_trylock() to avoid dead lock when handling a
>>> page fault while a TLB invalidate is requested by another CPU holding the
>>> PTE.
>>>
>>> In pseudo code, this could be seen as:
>>>     speculative_page_fault()
>>>     {
>>>             vma = get_vma()
>>>             check vma sequence count
>>>             check vma's support
>>>             disable interrupt
>>>                   check pgd,p4d,...,pte
>>>                   save pmd and pte in vmf
>>>                   save vma sequence counter in vmf
>>>             enable interrupt
>>>             check vma sequence count
>>>             handle_pte_fault(vma)
>>>                     ..
>>>                     page = alloc_page()
>>>                     pte_map_lock()
>>>                             disable interrupt
>>>                                     abort if sequence counter has changed
>>>                                     abort if pmd or pte has changed
>>>                                     pte map and lock
>>>                             enable interrupt
>>>                     if abort
>>>                        free page
>>>                        abort
>>>                     ...
>>>     }
>>>
>>>     arch_fault_handler()
>>>     {
>>>             if (speculative_page_fault(&vma))
>>>                goto done
>>>     again:
>>>             lock(mmap_sem)
>>>             vma = find_vma();
>>>             handle_pte_fault(vma);
>>>             if retry
>>>                unlock(mmap_sem)
>>>                goto again;
>>>     done:
>>>             handle fault error
>>>     }
>>>
>>> Support for THP is not done because when checking for the PMD, we can be
>>> confused by an in progress collapsing operation done by khugepaged. The
>>> issue is that pmd_none() could be true either if the PMD is not already
>>> populated or if the underlying PTE are in the way to be collapsed. So we
>>> cannot safely allocate a PMD if pmd_none() is true.
>>>
>>> This series add a new software performance event named 'speculative-faults'
>>> or 'spf'. It counts the number of successful page fault event handled
>>> speculatively. When recording 'faults,spf' events, the faults one is
>>> counting the total number of page fault events while 'spf' is only counting
>>> the part of the faults processed speculatively.
>>>
>>> There are some trace events introduced by this series. They allow
>>> identifying why the page faults were not processed speculatively. This
>>> doesn't take in account the faults generated by a monothreaded process
>>> which directly processed while holding the mmap_sem. This trace events are
>>> grouped in a system named 'pagefault', they are:
>>>  - pagefault:spf_vma_changed : if the VMA has been changed in our back
>>>  - pagefault:spf_vma_noanon : the vma->anon_vma field was not yet set.
>>>  - pagefault:spf_vma_notsup : the VMA's type is not supported
>>>  - pagefault:spf_vma_access : the VMA's access right are not respected
>>>  - pagefault:spf_pmd_changed : the upper PMD pointer has changed in our
>>>    back.
>>>
>>> To record all the related events, the easier is to run perf with the
>>> following arguments :
>>> $ perf stat -e 'faults,spf,pagefault:*' <command>
>>>
>>> There is also a dedicated vmstat counter showing the number of successful
>>> page fault handled speculatively. I can be seen this way:
>>> $ grep speculative_pgfault /proc/vmstat
>>>
>>> This series builds on top of v4.16-mmotm-2018-04-13-17-28 and is functional
>>> on x86, PowerPC and arm64.
>>>
>>> ---------------------
>>> Real Workload results
>>>
>>> As mentioned in previous email, we did non official runs using a "popular
>>> in memory multithreaded database product" on 176 cores SMT8 Power system
>>> which showed a 30% improvements in the number of transaction processed per
>>> second. This run has been done on the v6 series, but changes introduced in
>>> this new version should not impact the performance boost seen.
>>>
>>> Here are the perf data captured during 2 of these runs on top of the v8
>>> series:
>>>                 vanilla         spf
>>> faults          89.418          101.364         +13%
>>> spf                n/a           97.989
>>>
>>> With the SPF kernel, most of the page fault were processed in a speculative
>>> way.
>>>
>>> Ganesh Mahendran had backported the series on top of a 4.9 kernel and gave
>>> it a try on an android device. He reported that the application launch time
>>> was improved in average by 6%, and for large applications (~100 threads) by
>>> 20%.
>>>
>>> Here are the launch time Ganesh mesured on Android 8.0 on top of a Qcom
>>> MSM845 (8 cores) with 6GB (the less is better):
>>>
>>> Application                             4.9     4.9+spf delta
>>> com.tencent.mm                          416     389     -7%
>>> com.eg.android.AlipayGphone             1135    986     -13%
>>> com.tencent.mtt                         455     454     0%
>>> com.qqgame.hlddz                        1497    1409    -6%
>>> com.autonavi.minimap                    711     701     -1%
>>> com.tencent.tmgp.sgame                  788     748     -5%
>>> com.immomo.momo                         501     487     -3%
>>> com.tencent.peng                        2145    2112    -2%
>>> com.smile.gifmaker                      491     461     -6%
>>> com.baidu.BaiduMap                      479     366     -23%
>>> com.taobao.taobao                       1341    1198    -11%
>>> com.baidu.searchbox                     333     314     -6%
>>> com.tencent.mobileqq                    394     384     -3%
>>> com.sina.weibo                          907     906     0%
>>> com.youku.phone                         816     731     -11%
>>> com.happyelements.AndroidAnimal.qq      763     717     -6%
>>> com.UCMobile                            415     411     -1%
>>> com.tencent.tmgp.ak                     1464    1431    -2%
>>> com.tencent.qqmusic                     336     329     -2%
>>> com.sankuai.meituan                     1661    1302    -22%
>>> com.netease.cloudmusic                  1193    1200    1%
>>> air.tv.douyu.android                    4257    4152    -2%
>>>
>>> ------------------
>>> Benchmarks results
>>>
>>> Base kernel is v4.17.0-rc4-mm1
>>> SPF is BASE + this series
>>>
>>> Kernbench:
>>> ----------
>>> Here are the results on a 16 CPUs X86 guest using kernbench on a 4.15
>>> kernel (kernel is build 5 times):
>>>
>>> Average Half load -j 8
>>>                  Run    (std deviation)
>>>                  BASE                   SPF
>>> Elapsed Time     1448.65 (5.72312)      1455.84 (4.84951)       0.50%
>>> User    Time     10135.4 (30.3699)      10148.8 (31.1252)       0.13%
>>> System  Time     900.47  (2.81131)      923.28  (7.52779)       2.53%
>>> Percent CPU      761.4   (1.14018)      760.2   (0.447214)      -0.16%
>>> Context Switches 85380   (3419.52)      84748   (1904.44)       -0.74%
>>> Sleeps           105064  (1240.96)      105074  (337.612)       0.01%
>>>
>>> Average Optimal load -j 16
>>>                  Run    (std deviation)
>>>                  BASE                   SPF
>>> Elapsed Time     920.528 (10.1212)      927.404 (8.91789)       0.75%
>>> User    Time     11064.8 (981.142)      11085   (990.897)       0.18%
>>> System  Time     979.904 (84.0615)      1001.14 (82.5523)       2.17%
>>> Percent CPU      1089.5  (345.894)      1086.1  (343.545)       -0.31%
>>> Context Switches 159488  (78156.4)      158223  (77472.1)       -0.79%
>>> Sleeps           110566  (5877.49)      110388  (5617.75)       -0.16%
>>>
>>>
>>> During a run on the SPF, perf events were captured:
>>>  Performance counter stats for '../kernbench -M':
>>>          526743764      faults
>>>                210      spf
>>>                  3      pagefault:spf_vma_changed
>>>                  0      pagefault:spf_vma_noanon
>>>               2278      pagefault:spf_vma_notsup
>>>                  0      pagefault:spf_vma_access
>>>                  0      pagefault:spf_pmd_changed
>>>
>>> Very few speculative page faults were recorded as most of the processes
>>> involved are monothreaded (sounds that on this architecture some threads
>>> were created during the kernel build processing).
>>>
>>> Here are the kerbench results on a 80 CPUs Power8 system:
>>>
>>> Average Half load -j 40
>>>                  Run    (std deviation)
>>>                  BASE                   SPF
>>> Elapsed Time     117.152 (0.774642)     117.166 (0.476057)      0.01%
>>> User    Time     4478.52 (24.7688)      4479.76 (9.08555)       0.03%
>>> System  Time     131.104 (0.720056)     134.04  (0.708414)      2.24%
>>> Percent CPU      3934    (19.7104)      3937.2  (19.0184)       0.08%
>>> Context Switches 92125.4 (576.787)      92581.6 (198.622)       0.50%
>>> Sleeps           317923  (652.499)      318469  (1255.59)       0.17%
>>>
>>> Average Optimal load -j 80
>>>                  Run    (std deviation)
>>>                  BASE                   SPF
>>> Elapsed Time     107.73  (0.632416)     107.31  (0.584936)      -0.39%
>>> User    Time     5869.86 (1466.72)      5871.71 (1467.27)       0.03%
>>> System  Time     153.728 (23.8573)      157.153 (24.3704)       2.23%
>>> Percent CPU      5418.6  (1565.17)      5436.7  (1580.91)       0.33%
>>> Context Switches 223861  (138865)       225032  (139632)        0.52%
>>> Sleeps           330529  (13495.1)      332001  (14746.2)       0.45%
>>>
>>> During a run on the SPF, perf events were captured:
>>>  Performance counter stats for '../kernbench -M':
>>>          116730856      faults
>>>                  0      spf
>>>                  3      pagefault:spf_vma_changed
>>>                  0      pagefault:spf_vma_noanon
>>>                476      pagefault:spf_vma_notsup
>>>                  0      pagefault:spf_vma_access
>>>                  0      pagefault:spf_pmd_changed
>>>
>>> Most of the processes involved are monothreaded so SPF is not activated but
>>> there is no impact on the performance.
>>>
>>> Ebizzy:
>>> -------
>>> The test is counting the number of records per second it can manage, the
>>> higher is the best. I run it like this 'ebizzy -mTt <nrcpus>'. To get
>>> consistent result I repeated the test 100 times and measure the average
>>> result. The number is the record processes per second, the higher is the
>>> best.
>>>
>>>                 BASE            SPF             delta
>>> 16 CPUs x86 VM  742.57          1490.24         100.69%
>>> 80 CPUs P8 node 13105.4         24174.23        84.46%
>>>
>>> Here are the performance counter read during a run on a 16 CPUs x86 VM:
>>>  Performance counter stats for './ebizzy -mTt 16':
>>>            1706379      faults
>>>            1674599      spf
>>>              30588      pagefault:spf_vma_changed
>>>                  0      pagefault:spf_vma_noanon
>>>                363      pagefault:spf_vma_notsup
>>>                  0      pagefault:spf_vma_access
>>>                  0      pagefault:spf_pmd_changed
>>>
>>> And the ones captured during a run on a 80 CPUs Power node:
>>>  Performance counter stats for './ebizzy -mTt 80':
>>>            1874773      faults
>>>            1461153      spf
>>>             413293      pagefault:spf_vma_changed
>>>                  0      pagefault:spf_vma_noanon
>>>                200      pagefault:spf_vma_notsup
>>>                  0      pagefault:spf_vma_access
>>>                  0      pagefault:spf_pmd_changed
>>>
>>> In ebizzy's case most of the page fault were handled in a speculative way,
>>> leading the ebizzy performance boost.
>>>
>>> ------------------
>>> Changes since v10 (https://lkml.org/lkml/2018/4/17/572):
>>>  - Accounted for all review feedbacks from Punit Agrawal, Ganesh Mahendran
>>>    and Minchan Kim, hopefully.
>>>  - Remove unneeded check on CONFIG_SPECULATIVE_PAGE_FAULT in
>>>    __do_page_fault().
>>>  - Loop in pte_spinlock() and pte_map_lock() when pte try lock fails
>>>    instead
>>>    of aborting the speculative page fault handling. Dropping the now
>>> useless
>>>    trace event pagefault:spf_pte_lock.
>>>  - No more try to reuse the fetched VMA during the speculative page fault
>>>    handling when retrying is needed. This adds a lot of complexity and
>>>    additional tests done didn't show a significant performance improvement.
>>>  - Convert IS_ENABLED(CONFIG_NUMA) back to #ifdef due to build error.
>>>
>>> [1] http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
>>> [2] https://patchwork.kernel.org/patch/9999687/
>>>
>>>
>>> Laurent Dufour (20):
>>>   mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
>>>   x86/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>>>   powerpc/mm: set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>>>   mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
>>>   mm: make pte_unmap_same compatible with SPF
>>>   mm: introduce INIT_VMA()
>>>   mm: protect VMA modifications using VMA sequence count
>>>   mm: protect mremap() against SPF hanlder
>>>   mm: protect SPF handler against anon_vma changes
>>>   mm: cache some VMA fields in the vm_fault structure
>>>   mm/migrate: Pass vm_fault pointer to migrate_misplaced_page()
>>>   mm: introduce __lru_cache_add_active_or_unevictable
>>>   mm: introduce __vm_normal_page()
>>>   mm: introduce __page_add_new_anon_rmap()
>>>   mm: protect mm_rb tree with a rwlock
>>>   mm: adding speculative page fault failure trace events
>>>   perf: add a speculative page fault sw event
>>>   perf tools: add support for the SPF perf event
>>>   mm: add speculative page fault vmstats
>>>   powerpc/mm: add speculative page fault
>>>
>>> Mahendran Ganesh (2):
>>>   arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>>>   arm64/mm: add speculative page fault
>>>
>>> Peter Zijlstra (4):
>>>   mm: prepare for FAULT_FLAG_SPECULATIVE
>>>   mm: VMA sequence count
>>>   mm: provide speculative fault infrastructure
>>>   x86/mm: add speculative pagefault handling
>>>
>>>  arch/arm64/Kconfig                    |   1 +
>>>  arch/arm64/mm/fault.c                 |  12 +
>>>  arch/powerpc/Kconfig                  |   1 +
>>>  arch/powerpc/mm/fault.c               |  16 +
>>>  arch/x86/Kconfig                      |   1 +
>>>  arch/x86/mm/fault.c                   |  27 +-
>>>  fs/exec.c                             |   2 +-
>>>  fs/proc/task_mmu.c                    |   5 +-
>>>  fs/userfaultfd.c                      |  17 +-
>>>  include/linux/hugetlb_inline.h        |   2 +-
>>>  include/linux/migrate.h               |   4 +-
>>>  include/linux/mm.h                    | 136 +++++++-
>>>  include/linux/mm_types.h              |   7 +
>>>  include/linux/pagemap.h               |   4 +-
>>>  include/linux/rmap.h                  |  12 +-
>>>  include/linux/swap.h                  |  10 +-
>>>  include/linux/vm_event_item.h         |   3 +
>>>  include/trace/events/pagefault.h      |  80 +++++
>>>  include/uapi/linux/perf_event.h       |   1 +
>>>  kernel/fork.c                         |   5 +-
>>>  mm/Kconfig                            |  22 ++
>>>  mm/huge_memory.c                      |   6 +-
>>>  mm/hugetlb.c                          |   2 +
>>>  mm/init-mm.c                          |   3 +
>>>  mm/internal.h                         |  20 ++
>>>  mm/khugepaged.c                       |   5 +
>>>  mm/madvise.c                          |   6 +-
>>>  mm/memory.c                           | 612 +++++++++++++++++++++++++++++-----
>>>  mm/mempolicy.c                        |  51 ++-
>>>  mm/migrate.c                          |   6 +-
>>>  mm/mlock.c                            |  13 +-
>>>  mm/mmap.c                             | 229 ++++++++++---
>>>  mm/mprotect.c                         |   4 +-
>>>  mm/mremap.c                           |  13 +
>>>  mm/nommu.c                            |   2 +-
>>>  mm/rmap.c                             |   5 +-
>>>  mm/swap.c                             |   6 +-
>>>  mm/swap_state.c                       |   8 +-
>>>  mm/vmstat.c                           |   5 +-
>>>  tools/include/uapi/linux/perf_event.h |   1 +
>>>  tools/perf/util/evsel.c               |   1 +
>>>  tools/perf/util/parse-events.c        |   4 +
>>>  tools/perf/util/parse-events.l        |   1 +
>>>  tools/perf/util/python.c              |   1 +
>>>  44 files changed, 1161 insertions(+), 211 deletions(-)
>>>  create mode 100644 include/trace/events/pagefault.h
>>>
>>> --
>>> 2.7.4
>>>
>>>
>>
> 
