Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D6F136B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 10:16:41 -0400 (EDT)
Date: Thu, 7 May 2009 16:16:42 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86: 46 bit PAE support
Message-ID: <20090507141642.GJ481@elte.hu>
References: <20090505172856.6820db22@cuia.bos.redhat.com> <4A00ED83.1030700@zytor.com> <4A0180AB.20108@redhat.com> <20090507120103.GA1497@ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090507120103.GA1497@ucw.cz>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Rik van Riel <riel@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


* Pavel Machek <pavel@ucw.cz> wrote:

> On Wed 2009-05-06 08:20:59, Rik van Riel wrote:
> > H. Peter Anvin wrote:
> >> Rik van Riel wrote:
> >>> Testing: booted it on an x86-64 system with 6GB RAM.  Did you really think
> >>> I had access to a system with 64TB of RAM? :)
> >>
> >> No, but it would be good if we could test it under Qemu or KVM with an
> >> appropriately set up sparse memory map.
> >
> > I don't have a system with 1TB either, which is how much space
> > the memmap[] would take...
> 
> Do we really have 1 byte overhead per 64 bytes of RAM?
> 								Pavel

Yes, struct page is ~64 bytes, and 64*64 == 4096.

Alas, it's not a problem: my suggestion wasnt to simulate 64 TB of 
RAM. My suggestion was to create a sparse physical memory map (in a 
virtual machine) that spreads ~1GB of RAM all around the 64 TB 
physical address space. That will test whether the kernel is able to 
map and work with such physical addresses. (which will cover most of 
the issues)

A good look at /debug/x86/dump_pagetables with such a system booted 
up would be nice as well - to make sure every virtual memory range 
is in its proper area, and that there's enough free space around 
them.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
