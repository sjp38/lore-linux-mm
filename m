Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFD086B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 01:28:48 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id d134-v6so2587134lfd.10
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 22:28:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z191-v6sor82099lff.54.2018.03.08.22.28.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Mar 2018 22:28:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180308234800.GF29073@bombadil.infradead.org>
References: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
 <20180308222201.GB29073@bombadil.infradead.org> <20180308152244.2ba75bc2a766541ab8330eb0@linux-foundation.org>
 <20180308234800.GF29073@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 9 Mar 2018 11:58:45 +0530
Message-ID: <CAFqt6za4FtmThR2T0Gk-S8Y+-Wmke1D14yKwit4XaSL=12PCEw@mail.gmail.com>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Mar 9, 2018 at 5:18 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Thu, Mar 08, 2018 at 03:22:44PM -0800, Andrew Morton wrote:
>> On Thu, 8 Mar 2018 14:22:01 -0800 Matthew Wilcox <willy@infradead.org> wrote:
>> > On Thu, Mar 08, 2018 at 06:35:23PM +0530, Souptick Joarder wrote:
>> > > Use new return type vm_fault_t for fault handler
>> > > in struct vm_operations_struct.
>> > >
>> > > vmf_insert_mixed(), vmf_insert_pfn() and vmf_insert_page()
>> > > are newly added inline wrapper functions.
>> > >
>> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>> >
>> > Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>> >
>> > Andrew, the plan for these patches is to introduce the typedef, initially
>> > just as documentation ("This function should return a VM_FAULT_ status").
>> > We'll trickle the patches to individual drivers/filesystems in through
>> > the maintainers, as far as possible.  In a few months, we'll probably
>> > dump a pile of patches to unloved drivers on you for merging.  Then we'll
>> > change the typedef to an unsigned int and break the compilation of any
>> > unconverted driver.
>> >
>> > Souptick has done a few dozen drivers already, and I've been doing my best
>> > to keep up with reviewing the patches submitted.  There's some interesting
>> > patterns and commonalities between drivers (not to mention a few outright
>> > bugs) that we've noticed, and this'll be a good time to clean them up.
>>
>> OK.  All of this should be in the changelog, please.  Along with a full
>> explanation of the reasons for adding the new functions.
>
> Agreed.  Souptick, can you take care of doing that and resubmitting
> the patch?

Sure , I will add this into change log and resubmit the patch.

>
>> > It'd be great to get this into Linus' tree sooner so we can start
>> > submitting the patches to the driver maintainers.
>>
>> Sure.  I assume that vm_fault_t is `int', so this bare patch won't
>> cause a ton of type mismatch warnings?
>
> Exactly so.
