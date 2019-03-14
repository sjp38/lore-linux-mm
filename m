Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8615EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:40:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2615221019
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:40:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QePVWnrB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2615221019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA5F28E0004; Thu, 14 Mar 2019 05:40:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2D778E0001; Thu, 14 Mar 2019 05:40:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 944F28E0004; Thu, 14 Mar 2019 05:40:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB208E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:40:34 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id t9so1399023lji.0
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:40:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3p0kqhbvESA0lf+LNJgorCs0paew7ivQzsrBT/tqsy8=;
        b=gQIiqnjQvLJx8IrbDiD02VWmmtXVaqy56Yp9g0clm6a3mFma9CCl3I/nCt6/BVTFl3
         HhaeroR3h4VjvvO1z8BVK0S5GpHX53mT7p9NtYBtlMsPhOWzxv8g4pz6U7t/m/eBIC4I
         0G7v3+rUCKez0oSaxICB/XwnWozqcjIvVVUWgw+8F4k6fLdNC/++Z0OAE/cvfdJ+v8z9
         hhYkG1xypr8/OJLWoFyfiYs73T3MPgLjvd7F2P3rLAB4onbh/OGTeyjHo8WFnNCIil7w
         dFMBH9SRd4nE1BOaj5z/lt74poC5y9EjjgvDD2egABg6jjRSU3ACkv6bwnrtaLbIK5Fm
         A13Q==
X-Gm-Message-State: APjAAAUdELvT3O5K+qPOou1kvx9UPiV3ptzgf4l/NaaRcYEY0BI41zgg
	n+fytYp5juM1GrCpIpqkWBlQQnDoHSrvPVPe991yfCd+BK0f5WDeVInTpROJVOwV9dayF1uTnNN
	LVg+bpMQtlKdKO1sRe7RFFmkCoM6JS7KgLYAYkvvvJnuNUr6jVblV5cd9+0ZQIIGjwds3Zqn26D
	QLgbT2gLV8BWDSMRAc+BI4ZxnJ7Q3pCOSDLseK0kLhIlVWwEqMwSfOljVKwzJmrvE1wxmO7yfUG
	Mcjp8ouJ1bceonleGfMZkj0+FUMcVZWPfQ0FLuG4MXrwaCyNn7nSB6cGxhxPnirimc1u+1M1I2d
	RgHcVuNr6nlMa8brM5U0NMkPZoeGgtgRjWDHn05929bo/5KvT0wtnZCFAUPuBJROGgcoQVula0l
	1
X-Received: by 2002:a19:6609:: with SMTP id a9mr26846594lfc.47.1552556433239;
        Thu, 14 Mar 2019 02:40:33 -0700 (PDT)
X-Received: by 2002:a19:6609:: with SMTP id a9mr26846536lfc.47.1552556432030;
        Thu, 14 Mar 2019 02:40:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552556432; cv=none;
        d=google.com; s=arc-20160816;
        b=TH2dR95lUcg9Tos53mItejLmPeIYd0PM0ud9Kqvh2CZdxExMbNnowPBRsLv0EaX1IN
         9u9KpnbMgmO1k/RNVTPA7htiKy2dgcBkGMEJjsiD8oZ137X4dBxXR+bpFRxzfmSrLdFi
         /UN1nwuxs3/ZRd3K5It5dXKHw8Bn4o4S0BdBcPulrTHoPL6zdir7Jjt/OCr5NbZuoDzP
         JMXvAyV+pKi5/hoqHQ91ZfjIgi+Hpji7wWBO1guxxU8u9UokW5AiH/pQJQLdAwSfLhD/
         v5Fz+socPlgnaqaHMDaC3nORmywcA0javUN3UwJAUh5saMwq65iplw5KIfWSOjL+hF9f
         rYDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3p0kqhbvESA0lf+LNJgorCs0paew7ivQzsrBT/tqsy8=;
        b=f6K9PaHjuozXsQew0Kk1tDhuTzu1DAC2Oa8XCIoOOnmmkBZDn0zmPud5wP3Y5XR6of
         uqOS/U6mpjxzzLo6kYmqe4Fm0QSOb0j4f6HTCnO/gtO48uGGt7zVFVaV43NVsr6PlzPd
         5Bs9ZBqAktO8Db57VhkOcb3/iXr+IERm+w0zSu2gIdz7poS9z+EXKysr+RBZl0ZgCW7p
         oY7eJfXReVzqKqn2YQZ1LR5MHV+y/KyHL0Qgd9dalJyGcnypF62WJpo3qDImLOZNo0ba
         ssqHJX/yk0ZSBduTTRhNlXqK2GU4T1aik41vUB8btDbPL7ygHg0gi8ihmqN8fOotjb0Q
         BNmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QePVWnrB;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d16sor3670356ljg.1.2019.03.14.02.40.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 02:40:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QePVWnrB;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3p0kqhbvESA0lf+LNJgorCs0paew7ivQzsrBT/tqsy8=;
        b=QePVWnrBX4FhU0Tb5nyLPthUSaGE4CAAGNXvs/eUuXM8l1ky3f+okh/vh15XbZFHTq
         Xv/rCROlZA0Gv5nbJucigXBS5orR/1xJEFQLYfVG7nZn+dSPVxhHMNRAxK7+hFxJvG8j
         0GlodelXEyno6YWTOAW0XMxeCYfgbpJwjRBBo+JtmnaUdZRwWrOBngVnDbU+W5C365T7
         XrXOZjc8vE1zPbA6O2E+Cqq+8z9wGmGrJO0BuoAYTQnVLa4S95DsWQd5YcKW47N8QUlD
         FSE2bBxoAth7oqLLNZibtyCfD0OS+vJUb4RGK+mtiri4ivg8ZkZEuTCfyeUcYqqkChQO
         IpbQ==
X-Google-Smtp-Source: APXvYqyTX06+yGNFirdTcso2jqXuIqkKlemfadmZHn1M2wLF90gtcu58/CibFiLSyrLC7t2tC1cDGo6QLDdWsXVpygk=
X-Received: by 2002:a2e:9e4b:: with SMTP id g11mr2325527ljk.155.1552556431421;
 Thu, 14 Mar 2019 02:40:31 -0700 (PDT)
MIME-Version: 1.0
References: <201903140301.VeDCo2VR%lkp@intel.com>
In-Reply-To: <201903140301.VeDCo2VR%lkp@intel.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 14 Mar 2019 15:10:19 +0530
Message-ID: <CAFqt6zaA1t1+vPL8hk7Rm6B4ZqG6maK+Z1HAkL0aF93=q4MeOQ@mail.gmail.com>
Subject: Re: mm/memory.c:3968:21: sparse: incorrect type in assignment
 (different base types)
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, 
	William Kucharski <william.kucharski@oracle.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kbuild,

On Thu, Mar 14, 2019 at 12:50 AM kbuild test robot <lkp@intel.com> wrote:
>
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   5453a3df2a5eb49bc24615d4cf0d66b2aae05e5f
> commit: 3d3539018d2cbd12e5af4a132636ee7fd8d43ef0 mm: create the new vm_fault_t type
> date:   6 days ago
> reproduce:
>         # apt-get install sparse
>         git checkout 3d3539018d2cbd12e5af4a132636ee7fd8d43ef0
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
>
>
> sparse warnings: (new ones prefixed by >>)
>
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:149:22: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    include/asm-generic/tlb.h:150:20: sparse: expression using sizeof(void)
>    mm/memory.c:1275:31: sparse: expression using sizeof(void)
>    mm/memory.c:1275:31: sparse: expression using sizeof(void)
>    mm/memory.c:1280:15: sparse: expression using sizeof(void)
>    mm/memory.c:1280:15: sparse: expression using sizeof(void)
>    mm/memory.c:3389:24: sparse: expression using sizeof(void)
>    mm/memory.c:3389:24: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
>    mm/memory.c:3400:21: sparse: expression using sizeof(void)
> >> mm/memory.c:3968:21: sparse: incorrect type in assignment (different base types) @@    expected restricted vm_fault_t [usertype] ret @@    got e] ret @@
>    mm/memory.c:3968:21:    expected restricted vm_fault_t [usertype] ret
>    mm/memory.c:3968:21:    got int

Looking into https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
hugetlb_fault() is converted to return vm_fault_t. Not sure, why sparse is
still throwing warnings.

>    mm/memory.c:833:17: sparse: context imbalance in 'copy_pte_range' - different lock contexts for basic block
>    mm/memory.c:1436:16: sparse: context imbalance in '__get_locked_pte' - different lock contexts for basic block
>    mm/memory.c:1745:17: sparse: context imbalance in 'remap_pte_range' - different lock contexts for basic block
>    mm/memory.c:1978:17: sparse: context imbalance in 'apply_to_pte_range' - unexpected unlock
>    mm/memory.c:2427:17: sparse: context imbalance in 'wp_pfn_shared' - unexpected unlock
>    mm/memory.c:2489:19: sparse: context imbalance in 'do_wp_page' - different lock contexts for basic block
>    mm/memory.c:3071:19: sparse: context imbalance in 'pte_alloc_one_map' - different lock contexts for basic block
>    mm/memory.c:3314:17: sparse: context imbalance in 'finish_fault' - unexpected unlock
>    mm/memory.c:3426:9: sparse: context imbalance in 'do_fault_around' - unexpected unlock
>    mm/memory.c:4076:12: sparse: context imbalance in '__follow_pte_pmd' - different lock contexts for basic block
>    mm/memory.c:4153:5: sparse: context imbalance in 'follow_pte_pmd' - different lock contexts for basic block
>
> vim +3968 mm/memory.c
>
> ^1da177e Linus Torvalds     2005-04-16  3935
> 9a95f3cf Paul Cassella      2014-08-06  3936  /*
> 9a95f3cf Paul Cassella      2014-08-06  3937   * By the time we get here, we already hold the mm semaphore
> 9a95f3cf Paul Cassella      2014-08-06  3938   *
> 9a95f3cf Paul Cassella      2014-08-06  3939   * The mmap_sem may have been released depending on flags and our
> 9a95f3cf Paul Cassella      2014-08-06  3940   * return value.  See filemap_fault() and __lock_page_or_retry().
> 9a95f3cf Paul Cassella      2014-08-06  3941   */
> 2b740303 Souptick Joarder   2018-08-23  3942  vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
> dcddffd4 Kirill A. Shutemov 2016-07-26  3943            unsigned int flags)
> 519e5247 Johannes Weiner    2013-09-12  3944  {
> 2b740303 Souptick Joarder   2018-08-23  3945    vm_fault_t ret;
> 519e5247 Johannes Weiner    2013-09-12  3946
> 519e5247 Johannes Weiner    2013-09-12  3947    __set_current_state(TASK_RUNNING);
> 519e5247 Johannes Weiner    2013-09-12  3948
> 519e5247 Johannes Weiner    2013-09-12  3949    count_vm_event(PGFAULT);
> 2262185c Roman Gushchin     2017-07-06  3950    count_memcg_event_mm(vma->vm_mm, PGFAULT);
> 519e5247 Johannes Weiner    2013-09-12  3951
> 519e5247 Johannes Weiner    2013-09-12  3952    /* do counter updates before entering really critical section. */
> 519e5247 Johannes Weiner    2013-09-12  3953    check_sync_rss_stat(current);
> 519e5247 Johannes Weiner    2013-09-12  3954
> de0c799b Laurent Dufour     2017-09-08  3955    if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
> de0c799b Laurent Dufour     2017-09-08  3956                                        flags & FAULT_FLAG_INSTRUCTION,
> de0c799b Laurent Dufour     2017-09-08  3957                                        flags & FAULT_FLAG_REMOTE))
> de0c799b Laurent Dufour     2017-09-08  3958            return VM_FAULT_SIGSEGV;
> de0c799b Laurent Dufour     2017-09-08  3959
> 519e5247 Johannes Weiner    2013-09-12  3960    /*
> 519e5247 Johannes Weiner    2013-09-12  3961     * Enable the memcg OOM handling for faults triggered in user
> 519e5247 Johannes Weiner    2013-09-12  3962     * space.  Kernel faults are handled more gracefully.
> 519e5247 Johannes Weiner    2013-09-12  3963     */
> 519e5247 Johannes Weiner    2013-09-12  3964    if (flags & FAULT_FLAG_USER)
> 29ef680a Michal Hocko       2018-08-17  3965            mem_cgroup_enter_user_fault();
> 519e5247 Johannes Weiner    2013-09-12  3966
> bae473a4 Kirill A. Shutemov 2016-07-26  3967    if (unlikely(is_vm_hugetlb_page(vma)))
> bae473a4 Kirill A. Shutemov 2016-07-26 @3968            ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
> bae473a4 Kirill A. Shutemov 2016-07-26  3969    else
> dcddffd4 Kirill A. Shutemov 2016-07-26  3970            ret = __handle_mm_fault(vma, address, flags);
> 519e5247 Johannes Weiner    2013-09-12  3971
> 49426420 Johannes Weiner    2013-10-16  3972    if (flags & FAULT_FLAG_USER) {
> 29ef680a Michal Hocko       2018-08-17  3973            mem_cgroup_exit_user_fault();
> 49426420 Johannes Weiner    2013-10-16  3974            /*
> 49426420 Johannes Weiner    2013-10-16  3975             * The task may have entered a memcg OOM situation but
> 49426420 Johannes Weiner    2013-10-16  3976             * if the allocation error was handled gracefully (no
> 49426420 Johannes Weiner    2013-10-16  3977             * VM_FAULT_OOM), there is no need to kill anything.
> 49426420 Johannes Weiner    2013-10-16  3978             * Just clean up the OOM state peacefully.
> 49426420 Johannes Weiner    2013-10-16  3979             */
> 49426420 Johannes Weiner    2013-10-16  3980            if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> 49426420 Johannes Weiner    2013-10-16  3981                    mem_cgroup_oom_synchronize(false);
> 49426420 Johannes Weiner    2013-10-16  3982    }
> 3812c8c8 Johannes Weiner    2013-09-12  3983
> 519e5247 Johannes Weiner    2013-09-12  3984    return ret;
> 519e5247 Johannes Weiner    2013-09-12  3985  }
> e1d6d01a Jesse Barnes       2014-12-12  3986  EXPORT_SYMBOL_GPL(handle_mm_fault);
> 519e5247 Johannes Weiner    2013-09-12  3987
>
> :::::: The code at line 3968 was first introduced by commit
> :::::: bae473a423f65e480db83c85b5e92254f6dfcb28 mm: introduce fault_env
>
> :::::: TO: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

