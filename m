Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 328CCC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 20:21:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98D0520836
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 20:21:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98D0520836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E98238E0003; Sat,  2 Mar 2019 15:21:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E46708E0001; Sat,  2 Mar 2019 15:21:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0F128E0003; Sat,  2 Mar 2019 15:21:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83F048E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 15:21:24 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d5so1077920pfo.5
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 12:21:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=GM6+0Fcl7mMnmabfxHP5I9gbQsdMhNNRy2Vyk8hcNHI=;
        b=YB7wqyIOxOTyziplKKHoVTbGx/D+6UG74QXFAkvQgaf52vie+g2JSgllUssEFZ/UbU
         3N/zOfhxhha2WFiwpvaON8lQj5qtpcolALIv2OsWMtjPB6FX/9gHsC0MeSwR6oAcMT3I
         hOrWnUj8ywohpHNE6Vc/diHFI8ESlZcWdsUjQuUcRXlCL4axcRrk0lbGfb9k0tbt8fn0
         DgiNTtPtcuF13MzD/WoyMl8WJc2xjkQLtk7Ili9TXJEOcBymyxBioI9qRw4Hm9eEy3qr
         JkQ6RN5yQ9cdu7q1t6cr01VxbY1407G4ByytvUkaN0xiFF7jFEqq3lh8EnCkiDR0MD98
         uC1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVg5wIen+BH6C6TWRe/ocWa4lNBsObboGmQON02p3/uVla2xYyd
	044bTXxjtEMXLvQhD769xEpOSSDDGE6RhqMak/SumCI7Hc4XMcaW3+PWqeQmWGkmZ9nnLnJy1s1
	cuoaxBw+U0vKFVVtbsI+TLHpkOw3Hbzeqp2fz06O+RAVFK1rAfaJRT0lQjlauA6mVHw==
X-Received: by 2002:a63:5fce:: with SMTP id t197mr10954954pgb.415.1551558083646;
        Sat, 02 Mar 2019 12:21:23 -0800 (PST)
X-Google-Smtp-Source: APXvYqxhQqG1BhsUgTBY/yEIBGJ1nMGEdguFduXhJ1fwUcmBZs0EAg4gJLtRJfP6ypELhUUw51a3
X-Received: by 2002:a63:5fce:: with SMTP id t197mr10954867pgb.415.1551558081878;
        Sat, 02 Mar 2019 12:21:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551558081; cv=none;
        d=google.com; s=arc-20160816;
        b=xCGElCCoivFi4htJIfb3nSFrh1mgBySwHUOo1mp+P1OBVGXUtTykJwEK4svQ6WZZrM
         BVVL2aCjbeDQJdgze7loxYzUhLaxcjJ8io3ueEQFDPBTQIfJ99jFqprqgEalw3pgpUl7
         CElk1l2qQxiy7XIPj3fV2n+b4ktIfUsjfMrDhTtpkcHqNijKInNsEsuQYKM4wDQDZPEX
         bQ6wJdZb1T2Uh6t9+s6DCkb9Vy5U9C2jBG85K5c80zd4xpAJSHL4axNBz1xufhHblAg1
         gXXDsMg8ecsSD8F5pjOHZjlT6FaOaqX9hdqz7lYPgdgWc8vx7r9DAf1zNVFPx1hDn19T
         u+nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=GM6+0Fcl7mMnmabfxHP5I9gbQsdMhNNRy2Vyk8hcNHI=;
        b=niU0B64Dp61+KR8TLTHW6MIPB2CZqRvf31NBbLyTY6sOZyOwvQl/P1FLBdhXTdDH7Z
         NxdZ1XGi4aTPOF0uKEXDUMfdxtWv9Dev0e9OzxfRU7pNErvpD/4QHmwfZ0AT+5zCWuVO
         muz65hNQIHmlCMP2xAdotEeoJMJ9tFTT2pXLjhi6wz004CEhfa7gWFjp+IZDwG4h4eFu
         UfmGrBcs4KJU8P0f9bl2wAx0vC6mgHhcJ2rwFr/axwwxzrkmd9pKTTIZuxf9G0AIVBWx
         +diUYfHgS12ncax6L8Oh169psHn5Z+DU45pTwvc4kbWE1EVjFmmDDCPe9p50seAkhrdq
         lmog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 20si1311526pgr.200.2019.03.02.12.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 12:21:21 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Mar 2019 12:21:21 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,433,1544515200"; 
   d="gz'50?scan'50,208,50";a="120455217"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga006.jf.intel.com with ESMTP; 02 Mar 2019 12:21:19 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1h0B8I-000I0t-MY; Sun, 03 Mar 2019 04:21:18 +0800
Date: Sun, 3 Mar 2019 04:21:15 +0800
From: kbuild test robot <lkp@intel.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: kbuild-all@01.org, William Kucharski <william.kucharski@oracle.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [linux-next:master 11850/11910] mm/memory.c:3965:21: sparse:
 warning: incorrect type in assignment (different base types)
Message-ID: <201903030407.eYzqUpNl%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   c63e9e91a254a529716367234fd8093bb7b061ca
commit: 642e0b7a20093b29adaf0961b8a08983225c739d [11850/11910] mm: create the new vm_fault_t type
reproduce:
        # apt-get install sparse
        git checkout 642e0b7a20093b29adaf0961b8a08983225c739d
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

All warnings (new ones prefixed by >>):

   mm/memory.c:127:15: sparse: warning: symbol 'zero_pfn' was not declared. Should it be static?
>> mm/memory.c:3965:21: sparse: warning: incorrect type in assignment (different base types)
   mm/memory.c:3965:21: sparse:    expected restricted vm_fault_t [usertype] ret
   mm/memory.c:3965:21: sparse:    got int
   mm/memory.c:833:17: sparse: warning: context imbalance in 'copy_pte_range' - different lock contexts for basic block
   mm/memory.c:1436:16: sparse: warning: context imbalance in '__get_locked_pte' - different lock contexts for basic block
   mm/memory.c:1745:17: sparse: warning: context imbalance in 'remap_pte_range' - different lock contexts for basic block
   include/linux/spinlock.h:369:9: sparse: warning: context imbalance in 'apply_to_pte_range' - unexpected unlock
   include/linux/spinlock.h:369:9: sparse: warning: context imbalance in 'wp_pfn_shared' - unexpected unlock
   mm/memory.c:2489:19: sparse: warning: context imbalance in 'do_wp_page' - different lock contexts for basic block
   mm/memory.c:3071:19: sparse: warning: context imbalance in 'pte_alloc_one_map' - different lock contexts for basic block
   include/linux/spinlock.h:369:9: sparse: warning: context imbalance in 'finish_fault' - unexpected unlock
   mm/memory.c:3423:9: sparse: warning: context imbalance in 'do_fault_around' - unexpected unlock
   mm/memory.c:4073:12: sparse: warning: context imbalance in '__follow_pte_pmd' - different lock contexts for basic block
   mm/memory.c:4150:5: sparse: warning: context imbalance in 'follow_pte_pmd' - different lock contexts for basic block

sparse warnings: (new ones prefixed by >>)

   mm/memory.c:3965:21: sparse: warning: incorrect type in assignment (different base types)
>> mm/memory.c:3965:21: sparse:    expected restricted vm_fault_t [usertype] ret
>> mm/memory.c:3965:21: sparse:    got int
   mm/memory.c:833:17: sparse: warning: context imbalance in 'copy_pte_range' - different lock contexts for basic block
   mm/memory.c:1436:16: sparse: warning: context imbalance in '__get_locked_pte' - different lock contexts for basic block
   mm/memory.c:1745:17: sparse: warning: context imbalance in 'remap_pte_range' - different lock contexts for basic block
   include/linux/spinlock.h:369:9: sparse: warning: context imbalance in 'apply_to_pte_range' - unexpected unlock
   include/linux/spinlock.h:369:9: sparse: warning: context imbalance in 'wp_pfn_shared' - unexpected unlock
   mm/memory.c:2489:19: sparse: warning: context imbalance in 'do_wp_page' - different lock contexts for basic block
   mm/memory.c:3071:19: sparse: warning: context imbalance in 'pte_alloc_one_map' - different lock contexts for basic block
   include/linux/spinlock.h:369:9: sparse: warning: context imbalance in 'finish_fault' - unexpected unlock
   mm/memory.c:3423:9: sparse: warning: context imbalance in 'do_fault_around' - unexpected unlock
   mm/memory.c:4073:12: sparse: warning: context imbalance in '__follow_pte_pmd' - different lock contexts for basic block
   mm/memory.c:4150:5: sparse: warning: context imbalance in 'follow_pte_pmd' - different lock contexts for basic block

vim +3965 mm/memory.c

^1da177e Linus Torvalds     2005-04-16  3932  
9a95f3cf Paul Cassella      2014-08-06  3933  /*
9a95f3cf Paul Cassella      2014-08-06  3934   * By the time we get here, we already hold the mm semaphore
9a95f3cf Paul Cassella      2014-08-06  3935   *
9a95f3cf Paul Cassella      2014-08-06  3936   * The mmap_sem may have been released depending on flags and our
9a95f3cf Paul Cassella      2014-08-06  3937   * return value.  See filemap_fault() and __lock_page_or_retry().
9a95f3cf Paul Cassella      2014-08-06  3938   */
2b740303 Souptick Joarder   2018-08-23  3939  vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
dcddffd4 Kirill A. Shutemov 2016-07-26  3940  		unsigned int flags)
519e5247 Johannes Weiner    2013-09-12  3941  {
2b740303 Souptick Joarder   2018-08-23  3942  	vm_fault_t ret;
519e5247 Johannes Weiner    2013-09-12  3943  
519e5247 Johannes Weiner    2013-09-12  3944  	__set_current_state(TASK_RUNNING);
519e5247 Johannes Weiner    2013-09-12  3945  
519e5247 Johannes Weiner    2013-09-12  3946  	count_vm_event(PGFAULT);
2262185c Roman Gushchin     2017-07-06  3947  	count_memcg_event_mm(vma->vm_mm, PGFAULT);
519e5247 Johannes Weiner    2013-09-12  3948  
519e5247 Johannes Weiner    2013-09-12  3949  	/* do counter updates before entering really critical section. */
519e5247 Johannes Weiner    2013-09-12  3950  	check_sync_rss_stat(current);
519e5247 Johannes Weiner    2013-09-12  3951  
de0c799b Laurent Dufour     2017-09-08  3952  	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
de0c799b Laurent Dufour     2017-09-08  3953  					    flags & FAULT_FLAG_INSTRUCTION,
de0c799b Laurent Dufour     2017-09-08  3954  					    flags & FAULT_FLAG_REMOTE))
de0c799b Laurent Dufour     2017-09-08  3955  		return VM_FAULT_SIGSEGV;
de0c799b Laurent Dufour     2017-09-08  3956  
519e5247 Johannes Weiner    2013-09-12  3957  	/*
519e5247 Johannes Weiner    2013-09-12  3958  	 * Enable the memcg OOM handling for faults triggered in user
519e5247 Johannes Weiner    2013-09-12  3959  	 * space.  Kernel faults are handled more gracefully.
519e5247 Johannes Weiner    2013-09-12  3960  	 */
519e5247 Johannes Weiner    2013-09-12  3961  	if (flags & FAULT_FLAG_USER)
29ef680a Michal Hocko       2018-08-17  3962  		mem_cgroup_enter_user_fault();
519e5247 Johannes Weiner    2013-09-12  3963  
bae473a4 Kirill A. Shutemov 2016-07-26  3964  	if (unlikely(is_vm_hugetlb_page(vma)))
bae473a4 Kirill A. Shutemov 2016-07-26 @3965  		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
bae473a4 Kirill A. Shutemov 2016-07-26  3966  	else
dcddffd4 Kirill A. Shutemov 2016-07-26  3967  		ret = __handle_mm_fault(vma, address, flags);
519e5247 Johannes Weiner    2013-09-12  3968  
49426420 Johannes Weiner    2013-10-16  3969  	if (flags & FAULT_FLAG_USER) {
29ef680a Michal Hocko       2018-08-17  3970  		mem_cgroup_exit_user_fault();
49426420 Johannes Weiner    2013-10-16  3971  		/*
49426420 Johannes Weiner    2013-10-16  3972  		 * The task may have entered a memcg OOM situation but
49426420 Johannes Weiner    2013-10-16  3973  		 * if the allocation error was handled gracefully (no
49426420 Johannes Weiner    2013-10-16  3974  		 * VM_FAULT_OOM), there is no need to kill anything.
49426420 Johannes Weiner    2013-10-16  3975  		 * Just clean up the OOM state peacefully.
49426420 Johannes Weiner    2013-10-16  3976  		 */
49426420 Johannes Weiner    2013-10-16  3977  		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
49426420 Johannes Weiner    2013-10-16  3978  			mem_cgroup_oom_synchronize(false);
49426420 Johannes Weiner    2013-10-16  3979  	}
3812c8c8 Johannes Weiner    2013-09-12  3980  
519e5247 Johannes Weiner    2013-09-12  3981  	return ret;
519e5247 Johannes Weiner    2013-09-12  3982  }
e1d6d01a Jesse Barnes       2014-12-12  3983  EXPORT_SYMBOL_GPL(handle_mm_fault);
519e5247 Johannes Weiner    2013-09-12  3984  

:::::: The code at line 3965 was first introduced by commit
:::::: bae473a423f65e480db83c85b5e92254f6dfcb28 mm: introduce fault_env

:::::: TO: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--9amGYk9869ThD9tj
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AA==

--9amGYk9869ThD9tj--

