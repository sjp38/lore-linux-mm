Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6B27C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 11:35:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FFD12077C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 11:35:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FFD12077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 330AB6B0003; Tue, 23 Apr 2019 07:35:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DE956B0006; Tue, 23 Apr 2019 07:35:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4F26B0007; Tue, 23 Apr 2019 07:35:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C7F8F6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 07:35:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i17so7808296eds.21
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:35:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1IUR02oKZi1S2hadwNoroaCT+OypaFRyLXAVAo95G1o=;
        b=lot/AwXPMIROHI88ebIwYCruionFy2FIPhOjOnJIku+sgnJ7tKP8BwOefCjcHRwDoU
         b50zp0ssALstZa8iVGm8VEJvYyNIqk8TXSARJDwYQ6x0U9CwTHw/O0ddO9obwI/6JYN9
         DpIVe3DZ62M7aqyGc1hZLB7q9DzIuf39H1IHlnAW0JmVDCbw0nbihtp3+NzAOy4QU6gm
         sUuTJ7KGHMZ/OuVPOZYUcBq11pcnduVT27AlRi7xzkYXbsll3uXu3VQfGO+us2Glr9z6
         4pyPAageX8dSh5m/1LO93nv3EkzjzNLjydXn6FLl3LPUoH8ZF7vbYIEfJmi4SA1Em2tQ
         65vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWCn4soJHXMFBrMuiGswM8iGs2R6u3j8Us+78znze4tYydBhWVW
	5Vfls6K66p8P/uSvmWNdBZFGy5pOz0DG1uYDJNz6xvslqMu4wKyA2ua5B/HOhgZbrY+FGNXorh3
	iFG0gePA+ZkdtHNEb3E9/rCJcA435xqpvPt+kZHF3PHdrhTkYTcrffLMBY38AuwZ2pA==
X-Received: by 2002:a17:906:6410:: with SMTP id d16mr9149545ejm.75.1556019316378;
        Tue, 23 Apr 2019 04:35:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkwpJbk4FVysR3knGGoic4qTiLzSwlz5uV5+v8io/Q2A3iLPbxh06vRkYyHBZESmGY3IxJ
X-Received: by 2002:a17:906:6410:: with SMTP id d16mr9149485ejm.75.1556019314884;
        Tue, 23 Apr 2019 04:35:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556019314; cv=none;
        d=google.com; s=arc-20160816;
        b=viiJ3TTugUOC9eQnPLUvCc2XHSHOLo0goC5glJlEqoLMRYG0J/vu56I0TW7MuMNVyH
         3KY483CJFyRAnxIrMCfA2dDs1pRqW9m8LpKlMglBuR0cCRe6b4fYGLCpaENpX6EQXXZK
         aNr8gJrdjsIDLVjgUZHzVgknLmE7e56v17aMShnpYESUgDs5xfhCgxXTXoyyQpODOVR9
         Se7oosPtGrOOjfxYXnyW583WgO7N1voNdHk/SnPG4qXafqhDv0e7pvgEsbrw6tTWPJt3
         N2aGP1p1v8hg7PUYvf2uWQCNmfvcJ8Jr3O76QoO2Z0BKMgT523K3zX4dRaVOPsmFIJUd
         SR8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1IUR02oKZi1S2hadwNoroaCT+OypaFRyLXAVAo95G1o=;
        b=qCJj89g1myE08oAJ5ceBixT9dk0ibW/XI/bZS0kZFyZMVQCTAmGXUCLDvkY/58InaJ
         OwETAFQG3hGNPLFWWQLEdjWZ4uGAbxBTddH3OHibcKPqtnRL4xB9857JGIb6/LsLdq5P
         pdpcDfMp9MMM7RyKDTdkKgIFp9slzt24J7np7F9iDJz5iKrchlZ/ueC5RQjT2BYVFY5T
         2v3Q7Xv9EzB7uezlmKKhiERRx493QxMirWQ60IFoRNh2rOlbih/CjFHaKAmZyx90Jr7y
         UFeIetPy4UVW4EDOMEOGbwpAOKG67anKXntN+mvKyoiB/ZXTpHj5gQUVFgsJ/8uTkDQ7
         MBkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v18si1200385edl.312.2019.04.23.04.35.14
        for <linux-mm@kvack.org>;
        Tue, 23 Apr 2019 04:35:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B672DA78;
	Tue, 23 Apr 2019 04:35:13 -0700 (PDT)
Received: from [10.163.1.68] (unknown [10.163.1.68])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6DC143F557;
	Tue, 23 Apr 2019 04:35:00 -0700 (PDT)
Subject: Re: [PATCH v12 00/31] Speculative page faults
To: Laurent Dufour <ldufour@linux.ibm.com>, akpm@linux-foundation.org,
 mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name,
 ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz,
 Matthew Wilcox <willy@infradead.org>, aneesh.kumar@linux.ibm.com,
 benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
 sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
 Daniel Jordan <daniel.m.jordan@oracle.com>,
 David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>,
 Ganesh Mahendran <opensource.ganesh@gmail.com>,
 Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>,
 vinayak menon <vinayakm.list@gmail.com>,
 Yang Shi <yang.shi@linux.alibaba.com>, zhong jiang <zhongjiang@huawei.com>,
 Haiyan Song <haiyanx.song@intel.com>, Balbir Singh <bsingharora@gmail.com>,
 sj38.park@gmail.com, Michel Lespinasse <walken@google.com>,
 Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 haren@linux.vnet.ibm.com, npiggin@gmail.com, paulmck@linux.vnet.ibm.com,
 Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
 x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ecd1eb8c-d685-8c2e-1e1a-b167c8965075@arm.com>
Date: Tue, 23 Apr 2019 17:05:02 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/16/2019 07:14 PM, Laurent Dufour wrote:
> In pseudo code, this could be seen as:
>     speculative_page_fault()
>     {
> 	    vma = find_vma_rcu()
> 	    check vma sequence count
> 	    check vma's support
> 	    disable interrupt
> 		  check pgd,p4d,...,pte
> 		  save pmd and pte in vmf
> 		  save vma sequence counter in vmf
> 	    enable interrupt
> 	    check vma sequence count
> 	    handle_pte_fault(vma)
> 		    ..
> 		    page = alloc_page()
> 		    pte_map_lock()
> 			    disable interrupt
> 				    abort if sequence counter has changed
> 				    abort if pmd or pte has changed
> 				    pte map and lock
> 			    enable interrupt
> 		    if abort
> 		       free page
> 		       abort

Would not it be better if the 'page' allocated here can be passed on to handle_pte_fault()
below so that in the fallback path it does not have to enter the buddy again ? Of course
it will require changes to handle_pte_fault() to accommodate a pre-allocated non-NULL
struct page to operate on or free back into the buddy if fallback path fails for some
other reason. This will probably make SPF path less overhead for cases where it has to
fallback on handle_pte_fault() after pte_map_lock() in speculative_page_fault().

> 		    ...
> 	    put_vma(vma)
>     }
>     
>     arch_fault_handler()
>     {
> 	    if (speculative_page_fault(&vma))
> 	       goto done
>     again:
> 	    lock(mmap_sem)
> 	    vma = find_vma();
> 	    handle_pte_fault(vma);
> 	    if retry
> 	       unlock(mmap_sem)
> 	       goto again;
>     done:
> 	    handle fault error
>     }

- Anshuman

