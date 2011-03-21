Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 73E5F8D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 21:50:33 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2L1oFci018796
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 12:50:15 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2L1oHBD1908740
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 12:50:22 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2L1oHM7026555
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 12:50:17 +1100
Date: Mon, 21 Mar 2011 12:20:18 +1030
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [Resend] Cross Memory Attach v3 [PATCH]
Message-ID: <20110321122018.6306d067@lilo>
In-Reply-To: <20110317125427.eebbfb51.akpm@linux-foundation.org>
References: <20110315143547.1b233cd4@lilo>
 <20110315161623.4099664b.akpm@linux-foundation.org>
 <20110317154026.61ddd925@lilo>
 <20110317125427.eebbfb51.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 17 Mar 2011 12:54:27 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 17 Mar 2011 15:40:26 +1030
> Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> 
> > > Thinking out loud: if we had a way in which a process can add and
> > > remove a local anonymous page into pagecache then other processes
> > > could access that page via mmap.  If both processes map the file
> > > with a nonlinear vma they they can happily sit there flipping
> > > pages into and out of the shared mmap at arbitrary file offsets.
> > > The details might get hairy ;) We wouldn't want all the regular
> > > mmap semantics of
> > 
> > Yea, its the complexity of trying to do it that way that eventually
> > lead me to implementing it via a syscall and get_user_pages
> > instead, trying to keep things as simple as possible.
> 
> The pagecache trick potentially gives zero-copy access, whereas the
> proposed code is single-copy.  Although the expected benefits of that
> may not be so great due to TLB manipulation overheads.
> 
> I worry that one day someone will come along and implement the
> pagecache trick, then we're stuck with obsolete code which we have to
> maintain for ever.

Perhaps I don't understand what you're saying correctly but I think that
one problem with the zero copy page flipping approach is that there
is no guarantee with the data that the MPI apps want to send 
resides in a page or pages all by itself.

Regards, 

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
