Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6D55E6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 07:42:31 -0400 (EDT)
Received: by bwz21 with SMTP id 21so2524130bwz.38
        for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:43:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1244806872.7172.138.camel@pasglop>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
	 <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
	 <1244805060.7172.126.camel@pasglop>
	 <1244806440.30512.51.camel@penberg-laptop>
	 <1244806872.7172.138.camel@pasglop>
Date: Fri, 12 Jun 2009 14:43:50 +0300
Message-ID: <84144f020906120443w6496d408uadede7a8e1b772a@mail.gmail.com>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Fri, Jun 12, 2009 at 2:41 PM, Benjamin
Herrenschmidt<benh@kernel.crashing.org> wrote:
>> That said, Nick and Ingo seem to think special-casing is questionable
>> and I haven't had green light for any of the patches yet. The gfp
>> sanitization patch adds some overhead to kmalloc() and page allocator
>> paths which is obviously a concern.
>
> Let's wait and see what Linus thinks...

Yup, lets do that.

On Fri, Jun 12, 2009 at 2:41 PM, Benjamin
Herrenschmidt<benh@kernel.crashing.org> wrote:
>> So while we continue to discuss this, I'd really like to proceed with
>> the patch below. At least it should allow people to boot their kernels
>> (although it will produce warnings). I really don't want to keep other
>> people waiting for us to reach a resolution on this. Are you OK with
>> that?
>
> I don't care -how- we achieve the result I want as long as we achieve
> it, which is to remove the need for callers to care. My approach was one
> way to do it, I'm sure there's a better one. That's not the point. I'm
> too tried now to properly review your patch and I'll need to test it
> tomorrow morning, but it looks ok except for the WARN_ON maybe.

OK, the WARN_ON is there because you will get warnings for
might_sleep() et al as well.

                                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
