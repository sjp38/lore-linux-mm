Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C9A6F6B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 06:11:33 -0400 (EDT)
Received: by fxm12 with SMTP id 12so108947fxm.38
        for <linux-mm@kvack.org>; Fri, 12 Jun 2009 03:11:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090612100756.GA25185@elte.hu>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
Date: Fri, 12 Jun 2009 13:11:52 +0300
Message-ID: <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Fri, Jun 12, 2009 at 1:07 PM, Ingo Molnar<mingo@elte.hu> wrote:
> IMHO such invisible side-channels modifying the semantics of GFP
> flags is a bit dubious.
>
> We could do GFP_INIT or GFP_BOOT. These can imply other useful
> modifiers as well: panic-on-failure for example. (this would clean
> up a fair amount of init code that currently checks for an panics on
> allocation failure.)

OK, but that means we need to fix up every single caller. I'm fine
with that but Ben is not. As I am unable to test powerpc here, I am
inclined to just merge Ben's patch as "obviously correct".

That does not mean we can't introduce GFP_BOOT later on if we want to. Hmm?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
