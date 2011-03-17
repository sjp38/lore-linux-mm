Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 89D3C8D0046
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 15:56:27 -0400 (EDT)
Date: Thu, 17 Mar 2011 12:54:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Resend] Cross Memory Attach v3 [PATCH]
Message-Id: <20110317125427.eebbfb51.akpm@linux-foundation.org>
In-Reply-To: <20110317154026.61ddd925@lilo>
References: <20110315143547.1b233cd4@lilo>
	<20110315161623.4099664b.akpm@linux-foundation.org>
	<20110317154026.61ddd925@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 17 Mar 2011 15:40:26 +1030
Christopher Yeoh <cyeoh@au1.ibm.com> wrote:

> > Thinking out loud: if we had a way in which a process can add and
> > remove a local anonymous page into pagecache then other processes
> > could access that page via mmap.  If both processes map the file with
> > a nonlinear vma they they can happily sit there flipping pages into
> > and out of the shared mmap at arbitrary file offsets.  The details
> > might get hairy ;) We wouldn't want all the regular mmap semantics of
> 
> Yea, its the complexity of trying to do it that way that eventually lead me
> to implementing it via a syscall and get_user_pages instead, trying to 
> keep things as simple as possible.

The pagecache trick potentially gives zero-copy access, whereas the
proposed code is single-copy.  Although the expected benefits of that
may not be so great due to TLB manipulation overheads.

I worry that one day someone will come along and implement the
pagecache trick, then we're stuck with obsolete code which we have to
maintain for ever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
