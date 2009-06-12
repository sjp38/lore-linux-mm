Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 547926B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:01:14 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.DEB.1.10.0906120944540.15809@gentwo.org>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <1244796045.7172.82.camel@pasglop>
	 <1244796211.30512.32.camel@penberg-laptop>
	 <1244796837.7172.95.camel@pasglop>
	 <1244797659.30512.37.camel@penberg-laptop>
	 <alpine.DEB.1.10.0906120944540.15809@gentwo.org>
Content-Type: text/plain
Date: Sat, 13 Jun 2009 00:00:59 +1000
Message-Id: <1244815259.7172.167.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 09:49 -0400, Christoph Lameter wrote:
> On Fri, 12 Jun 2009, Pekka Enberg wrote:
> 
> > So I am sending the GFP_NOWAIT conversion for boot code even though you
> > didn't seem to like it (but didn't explicitly NAK) as it fixes problems
> > on x86.
> 
> The use GFP_NOWAIT means that the caller sites are still special cased for
> an early boot situation. After bootstrap is complete the sites may use
> GFP_KERNEL instead. Bad.

Amen :-)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
