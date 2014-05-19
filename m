Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id C2AC26B0037
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:16:47 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6163315pbb.5
        for <linux-mm@kvack.org>; Mon, 19 May 2014 11:16:47 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id qe5si10201889pbc.195.2014.05.19.11.16.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 May 2014 11:16:47 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 20 May 2014 04:16:42 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 0870C2CE8040
	for <linux-mm@kvack.org>; Tue, 20 May 2014 04:16:37 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4JIGLkd4653406
	for <linux-mm@kvack.org>; Tue, 20 May 2014 04:16:21 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4JIGaHx021832
	for <linux-mm@kvack.org>; Tue, 20 May 2014 04:16:36 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC, PATCH] mm: unified interface to handle page table entries on different levels?
In-Reply-To: <20140519002543.GA3899@node.dhcp.inet.fi>
References: <1400286785-26639-1-git-send-email-kirill.shutemov@linux.intel.com> <20140518234559.GG6121@linux.intel.com> <20140519002543.GA3899@node.dhcp.inet.fi>
Date: Mon, 19 May 2014 23:46:32 +0530
Message-ID: <87fvk5k51b.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave@sr71.net, riel@redhat.com, mgorman@suse.de, aarcange@redhat.com

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Sun, May 18, 2014 at 07:45:59PM -0400, Matthew Wilcox wrote:
>> On Sat, May 17, 2014 at 03:33:05AM +0300, Kirill A. Shutemov wrote:
>> > Below is my attempt to play with the problem. I've took one function --
>> > page_referenced_one() -- which looks ugly because of different APIs for
>> > PTE/PMD and convert it to use vpte_t. vpte_t is union for pte_t, pmd_t
>> > and pud_t.
>> > 
>> > Basically, the idea is instead of having different helpers to handle
>> > PTE/PMD/PUD, we have one, which take pair of vpte_t + pglevel.
>> 
>> I can't find my original attempt at this now (I am lost in a maze of
>> twisted git trees, all subtly different), but I called it a vpe (Virtual
>> Page Entry).
>> 
>> Rather than using a pair of vpte_t and pglevel, the vpe_t contained
>> enough information to discern what level it was; that's only two bits
>> and I think all the architectures have enough space to squeeze in two
>> more bits to the PTE (the PMD and PUD obviously have plenty of space).
>
> I'm not sure if it's possible to find a single free bit on all
> architectures. Two is near impossible.

On ppc64 we don't have any free bits.

>
> And what about 5-level page tables in future? Will we need 3 bits there?
> No way.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
