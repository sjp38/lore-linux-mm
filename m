Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF0255F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 14:34:58 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3EIVuX2027700
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 14:31:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3EIZTh5120118
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 14:35:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3EIXkQj001097
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 14:33:47 -0400
Subject: Re: [feedback] procps and new kernel fields
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <e2e108260904070602p61b0be4fpc257f850b004c49f@mail.gmail.com>
References: <1239054936.8846.130.camel@nimitz>
	 <787b0d920904062140n72b82c7mfc6ca78c291363f7@mail.gmail.com>
	 <e2e108260904070602p61b0be4fpc257f850b004c49f@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 14 Apr 2009 11:35:24 -0700
Message-Id: <1239734124.32604.100.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bart Van Assche <bart.vanassche@gmail.com>
Cc: Albert Cahalan <acahalan@cs.uml.edu>, linux-mm <linux-mm@kvack.org>, procps-feedback@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-07 at 15:02 +0200, Bart Van Assche wrote:
> On Tue, Apr 7, 2009 at 6:40 AM, Albert Cahalan <acahalan@cs.uml.edu> wrote:
> > On Mon, Apr 6, 2009 at 5:55 PM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> >> Novell has integrated that patch into procps
> >...
> >> The most worrisome side-effect of this change to me is that we can no
> >> longer run vmstat or free on two machines and compare their output.
> >
> > Right. Vendors never consier that. They then expect upstream
> > to accept and support their hack until the end of time.
> 
> The patch that was integrated by this vendor in their procps package
> was posted on a public mailing list more than a year ago. It would
> have helped if someone would have commented earlier on that patch.

We suck. :)

> >> We could also add some information which is in
> >> addition to what we already provide in order to account for things like
> >> slab more precisely.
> >
> > How do I even explain a slab? What about a slob or slub?
> > A few years from now, will this allocator even exist?
> >
> > Remember that I need something for the man page, and most
> > of my audience knows almost nothing about programming.
> 
> It's not the difference between SLAB, SLOB and SLUB that matters here,
> but the fact that some of the memory allocated by these kernel
> allocators can be reclaimed. The procps tools currently count
> reclaimable SLAB / SLOB / SLUB memory as used memory, which is
> misleading. How can this be explained to someone who is not a
> programmer ?

I actually think it is probably OK to call them "cache".  They *are*
quite similar to the page cache from a user's perspective.  I just have
a problem with changing it *now*, though.

Page cache is fundamentally user data.  It is verbatim in memory exactly
what came off or is going to the filesystem, and gets exposed to
userspace directly.

The various sl*bs are fundamentally kernel data.  They're never seen by
users directly.  

So, if I were to write a tool that told users of both slab and page
cache, I'd probably say "file cache" and "kernel cache" or something to
that effect.  It's a bit over-simplified, but I think it gets the point
across sufficiently.  Personally, I'd probably rather see 'buffers' get
collapsed in with 'cache' and get a new column for sl*b.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
