Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 641FE6B0006
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 14:26:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d22-v6so5851318pfn.3
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 11:26:47 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id a17-v6si10733218pgb.369.2018.08.10.11.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 11:26:46 -0700 (PDT)
Subject: Re: [RFC v7 PATCH 2/4] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180810175759.GB6487@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <0594c845-68c8-e15f-6ec6-91641c5fbdd1@linux.alibaba.com>
Date: Fri, 10 Aug 2018 11:26:14 -0700
MIME-Version: 1.0
In-Reply-To: <20180810175759.GB6487@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/10/18 10:57 AM, Matthew Wilcox wrote:
> On Fri, Aug 10, 2018 at 07:36:01AM +0800, Yang Shi wrote:
>> +/*
>> + * Zap pages with read mmap_sem held
>> + *
>> + * uf is the list for userfaultfd
>> + */
>> +static int do_munmap_zap_rlock(struct mm_struct *mm, unsigned long start,
>> +			       size_t len, struct list_head *uf)
> I don't like the name here.  We aren't zapping rlocks, we're zapping
> pages.  Not sure what to call it though ...

It may look ambiguous, it means "zap with rlock", but I don't think 
anyone would expect we are zapping locks.

Thanks,
Yang
