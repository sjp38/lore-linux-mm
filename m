Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F334A6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:05:27 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1244796837.7172.95.camel@pasglop>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <1244796045.7172.82.camel@pasglop>
	 <1244796211.30512.32.camel@penberg-laptop>
	 <1244796837.7172.95.camel@pasglop>
Date: Fri, 12 Jun 2009 12:05:33 +0300
Message-Id: <1244797533.30512.35.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 18:53 +1000, Benjamin Herrenschmidt wrote:
> Now, if you find it a bit too ugly, feel free to rename smellybits to
> something else and create an accessor function for setting what bits are
> masked out, but I still believe that the basic idea behind my patch is
> saner than yours :-)

It's not the naming I object to but the mechanism because I think is
open for abuse (think smelly driver playing tricks with it). So I do
think my patch is the sanest solution here. ;-)

Nick? Christoph?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
