Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 924236B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 02:16:31 -0400 (EDT)
Date: Fri, 12 Jun 2009 09:16:57 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: slab: setup allocators earlier in the boot sequence
In-Reply-To: <1244783235.7172.61.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Hi Benjamin,

[ First of all, sorry for the breakage and thank you for looking into 
  this! ]

On Fri, 12 Jun 2009, Benjamin Herrenschmidt wrote:
> > I'll cook up a patch that defines a global bitmask of "forbidden" GFP
> > bits and see how things go.
> 
> >From ad87215e01b257ccc1af64aa9d5776ace580dea3 Mon Sep 17 00:00:00 2001
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Fri, 12 Jun 2009 15:03:47 +1000
> Subject: [PATCH] Sanitize "gfp" flags during boot

OK, I am not sure we actually need that. The thing is, no one is allowed 
to use kmalloc() unless slab_is_available() returns true so we can just 
grep for the latter and do something like the following patch. Does that 
make powerpc boot nicely again? Ingo, I think this fixes the early irq 
screams you were having too.

There's some more in s390 architecture code and some drivers (!) but I 
left them out from this patch for now.

			Pekka
