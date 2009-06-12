Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F01B6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 07:10:56 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
	 <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 21:11:00 +1000
Message-Id: <1244805060.7172.126.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


> OK, but that means we need to fix up every single caller. I'm fine
> with that but Ben is not. As I am unable to test powerpc here, I am
> inclined to just merge Ben's patch as "obviously correct".
> 
> That does not mean we can't introduce GFP_BOOT later on if we want to. Hmm?

Again, you are missing part of the picture. Yes we -can- fix all the
-direct- callers that are obviously only be run at boot time. But what
about all the indirect ones (or even direct ones) that can be called
either at boot time or later. vmalloc() is the perfect example (or more
precisely __get_vm_area() which brings in ioremap etc...) but there are
many more.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
