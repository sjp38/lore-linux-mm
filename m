Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E0706B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 09:43:18 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1D37B82C56B
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:00:23 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PySvO0ZkiiZY for <linux-mm@kvack.org>;
	Fri, 12 Jun 2009 10:00:23 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1127382C609
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:00:00 -0400 (EDT)
Date: Fri, 12 Jun 2009 09:44:04 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: slab: setup allocators earlier in the boot sequence
In-Reply-To: <1244796211.30512.32.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0906120941550.15809@gentwo.org>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>  <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>  <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>  <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
  <1244792079.7172.74.camel@pasglop>  <1244792745.30512.13.camel@penberg-laptop>  <1244796045.7172.82.camel@pasglop> <1244796211.30512.32.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009, Pekka Enberg wrote:

> Yes, you're obviously right. I overlooked the fact that arch code have
> their own special slab_is_available() heuristics (yikes!).

Thats another area where we would need some cleanup in the future. The
slab_is_available() has become a check for the end of the use of bootmem.

What would be clearer is to have something like

allocator_bootstrap_complete()

to tell us that all memory allocators are available (slab, page, percpu,
vmalloc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
