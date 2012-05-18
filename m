Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4F61F6B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 09:33:12 -0400 (EDT)
Date: Fri, 18 May 2012 15:32:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Hole punching and mmap races
Message-ID: <20120518133250.GC5589@quack.suse.cz>
References: <20120515224805.GA25577@quack.suse.cz>
 <20120516021423.GO25351@dastard>
 <20120516130445.GA27661@quack.suse.cz>
 <20120517074308.GQ25351@dastard>
 <20120517232829.GA31028@quack.suse.cz>
 <20120518101210.GX25351@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120518101210.GX25351@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Fri 18-05-12 20:12:10, Dave Chinner wrote:
> On Fri, May 18, 2012 at 01:28:29AM +0200, Jan Kara wrote:
> > On Thu 17-05-12 17:43:08, Dave Chinner wrote:
> > > On Wed, May 16, 2012 at 03:04:45PM +0200, Jan Kara wrote:
> > > > On Wed 16-05-12 12:14:23, Dave Chinner wrote:
> > > IIRC, it's a rare case (that I consider insane, BTW):  read from a
> > > file with into a buffer that is a mmap()d region of the same file
> > > that has not been faulted in yet.....
> >   With punch hole, the race is less insane - just punching hole in the area
> > which is accessed via mmap could race in a bad way AFAICS.
> 
> Seems the simple answer to me is to prevent page faults while hole
> punching, then....
  Yes, that's what I was suggesting in the beginning :) And I was asking
whether people are OK with another lock in the page fault path (in
particular in ->page_mkwrite) or whether someone has a better idea (e.g.
taking mmap_sem in the hole punching path seems possible but I'm not sure
whether that would be considered acceptable abuse).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
