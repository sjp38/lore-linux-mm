Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0204E6B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 03:34:06 -0400 (EDT)
Received: by fxm24 with SMTP id 24so1092363fxm.38
        for <linux-mm@kvack.org>; Thu, 18 Jun 2009 00:35:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A39E377.9060207@kernel.org>
References: <20090617203337.399182817@gentwo.org>
	 <20090617203445.302169275@gentwo.org>
	 <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
	 <4A39E377.9060207@kernel.org>
Date: Thu, 18 Jun 2009 10:35:09 +0300
Message-ID: <84144f020906180035n7d75f455jfbd8d7d80b9a2982@mail.gmail.com>
Subject: Re: [this_cpu_xx V2 13/19] Use this_cpu operations in slub
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Tejun,

On Thu, Jun 18, 2009 at 9:49 AM, Tejun Heo<tj@kernel.org> wrote:
>> So I don't think the above hunk is a good solution to this at all. We
>> certainly can remove the lazy DMA slab creation (why did we add it in
>> the first place?) but how hard is it to fix the per-cpu allocator to
>> work in atomic contexts?
>
> Should be possible but I wanna avoid that as long as possible. =A0Atomic
> allocations suck anyway... =A0:-(

OK, but I suspect this could turn into an issue as people start using
kmalloc() earlier in the boot sequence (where interrupts are disabled)
and will likely expect other allocators to work there too.

                                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
