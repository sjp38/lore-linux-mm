Date: Mon, 29 Jan 2007 17:41:18 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-Id: <20070129174118.0e922ab3.akpm@osdl.org>
In-Reply-To: <45BE9FE8.4080603@mbligh.org>
References: <1169993494.10987.23.camel@lappy>
	<20070128142925.df2f4dce.akpm@osdl.org>
	<1170063848.6189.121.camel@twins>
	<45BE9FE8.4080603@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007 17:31:20 -0800
"Martin J. Bligh" <mbligh@mbligh.org> wrote:

> Peter Zijlstra wrote:
> > On Sun, 2007-01-28 at 14:29 -0800, Andrew Morton wrote:
> > 
> >> As Christoph says, it's very much preferred that code be migrated over to
> >> kmap_atomic().  Partly because kmap() is deadlockable in situations where a
> >> large number of threads are trying to take two kmaps at the same time and
> >> we run out.  This happened in the past, but incidences have gone away,
> >> probably because of kmap->kmap_atomic conversions.
> > 
> >> From which callsite have you measured problems?
> > 
> > CONFIG_HIGHPTE code in -rt was horrid. I'll do some measurements on
> > mainline.
> > 
> 
> CONFIG_HIGHPTE is always horrid -we've known that for years.

We have?  What's wrong with it?  <looks around for bug reports>

> Don't use it.
> 
> If that's all we're fixing here, I'd be highly suspect ...

highpte uses atomic kmaps - it is unrelated to this work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
