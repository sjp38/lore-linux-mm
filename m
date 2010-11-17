Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A896C8D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 02:28:06 -0500 (EST)
Date: Tue, 16 Nov 2010 23:24:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
Message-Id: <20101116232427.c614d12e.akpm@linux-foundation.org>
In-Reply-To: <ED9181FA-6B0E-4A7B-AA2D-7B976A876557@oracle.com>
References: <1289421759.11149.59.camel@oralap>
	<20101111120643.22dcda5b.akpm@linux-foundation.org>
	<1289512924.428.112.camel@oralap>
	<20101111142511.c98c3808.akpm@linux-foundation.org>
	<1289840500.13446.65.camel@oralap>
	<alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
	<20101116141130.b20a8a8d.akpm@linux-foundation.org>
	<ED9181FA-6B0E-4A7B-AA2D-7B976A876557@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <andreas.dilger@oracle.com>
Cc: David Rientjes <rientjes@google.com>, "Ricardo M. Correia" <ricardo.correia@oracle.com>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 01:18:27 -0600 Andreas Dilger <andreas.dilger@oracle.com> wrote:

> On 2010-11-16, at 16:11, Andrew Morton wrote:
> > On Mon, 15 Nov 2010 13:28:54 -0800 (PST)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> >> - avoid doing anything other than GFP_KERNEL allocations for __vmalloc():
> >>   the only current users are gfs2, ntfs, and ceph (the page allocator
> >>   __vmalloc() can be discounted since it's done at boot and GFP_ATOMIC
> >>   here has almost no chance of failing since the size is determined based 
> >>   on what is available).
> > 
> > ^^ this
> > 
> > Using vmalloc anywhere is lame.
> 
> I agree.  What we really want is 1MB kmalloc() to work...  :-/

meh.  Thinking that you require 1MB of virtually contiguous memory in
kernel code is lame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
