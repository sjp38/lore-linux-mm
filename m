Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 158346B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 11:03:12 -0400 (EDT)
Date: Sun, 31 May 2009 08:03:04 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090531080304.6e195c14@infradead.org>
In-Reply-To: <20090531073826.567d1dc3@infradead.org>
References: <20090522073436.GA3612@elte.hu>
	<20090522113809.GB13971@oblivion.subreption.com>
	<20090522143914.2019dd47@lxorguk.ukuu.org.uk>
	<20090522180351.GC13971@oblivion.subreption.com>
	<20090522192158.28fe412e@lxorguk.ukuu.org.uk>
	<20090522234031.GH13971@oblivion.subreption.com>
	<20090523090910.3d6c2e85@lxorguk.ukuu.org.uk>
	<20090523085653.0ad217f8@infradead.org>
	<1243539361.6645.80.camel@laptop>
	<20090529073217.08eb20e1@infradead.org>
	<20090530054856.GG29711@oblivion.subreption.com>
	<1243679973.6645.131.camel@laptop>
	<20090531073826.567d1dc3@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Sun, 31 May 2009 07:38:26 -0700
Arjan van de Ven <arjan@infradead.org> wrote:

> > 
> > 
> > Really, get a life, go fix real bugs. Don't make our kernel slower 
> 
> the "make it slower" is an assumption on your part.
> I'm not convinced. Would like to see data!
> 


btw if the performance difference is basically a wash (as I'm
suspecting), then we SHOULD do zero-on-free, just out of general
principles. 

Ingo mentioned the kernel stack, and that's a good point, we ought
to have a way to zero the rest of the stack inside the kernel, at
which point you could do things like providing a command line option
(or sysctl?) to call that from the munmap codepath or so...
(after all there you do a tlb flush and other expensive things as well)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
