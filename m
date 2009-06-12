Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0105E6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:48:01 -0400 (EDT)
Received: by fxm12 with SMTP id 12so58943fxm.38
        for <linux-mm@kvack.org>; Fri, 12 Jun 2009 01:49:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1244796291.7172.87.camel@pasglop>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <20090612075427.GA24044@wotan.suse.de>
	 <1244793592.30512.17.camel@penberg-laptop>
	 <20090612080236.GB24044@wotan.suse.de>
	 <1244793879.30512.19.camel@penberg-laptop>
	 <1244796291.7172.87.camel@pasglop>
Date: Fri, 12 Jun 2009 11:49:31 +0300
Message-ID: <84144f020906120149k6cbe5177vef1944d9d216e8b2@mail.gmail.com>
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 11:44 AM, Benjamin
Herrenschmidt<benh@kernel.crashing.org> wrote:
> On Fri, 2009-06-12 at 11:04 +0300, Pekka Enberg wrote:
>> Hi Nick,
>>
>> On Fri, 2009-06-12 at 10:02 +0200, Nick Piggin wrote:
>> > Fair enough, but this can be done right down in the synchronous
>> > reclaim path in the page allocator. This will catch more cases
>> > of code using the page allocator directly, and should be not
>> > as hot as the slab allocator.
>>
>> So you want to push the local_irq_enable() to the page allocator too? We
>> can certainly do that but I think we ought to wait for Andrew to merge
>> Mel's patches to mainline first, OK?
>
> Doesn't my patch take care of all the cases in a much more simple way ?

Nick, the patch Ben is talking about is here:

http://patchwork.kernel.org/patch/29700/

The biggest problem with the patch is that the gfp_smellybits is wide
open for abuse. Hmm.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
