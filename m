Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0836B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 06:51:26 -0500 (EST)
Date: Fri, 6 Feb 2009 12:50:46 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
Message-ID: <20090206115045.GA1580@cmpxchg.org>
References: <20090206031125.693559239@cmpxchg.org> <20090206031324.004715023@cmpxchg.org> <20090206080354.GA6516@barrios-desktop> <28c262360902060206h78c15a1dsf52b481c5cc1bc74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360902060206h78c15a1dsf52b481c5cc1bc74@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 06, 2009 at 07:06:34PM +0900, MinChan Kim wrote:
> On Fri, Feb 6, 2009 at 5:03 PM, MinChan Kim <minchan.kim@gmail.com> wrote:
> >> Another reason for preferring file page eviction is that the locality
> >> principle is visible in fault patterns and swap might perform really
> >> bad with subsequent faulting of contiguously mapped pages.
> >
> > Why do you think that swap might perform bad with subsequent faulting
> > of contiguusly mapped page ?
> > You mean normal file system is faster than swap due to readahead and
> > smart block of allocation ?
> 
> But, I still can't understand this issue.
> what mean "page eviction" ? Is it reclaim or swap out ?

Reclaim evicts pages from memory by swap out (and writeback).

In the suspend case, "reclaim" is perhaps not 100% correct.  We are
not directly interested in the amount of free pages as you are with
reclaim, but interested in the amount of pages in use as those are the
pages we have to write to disk.  So "shrinking" is the better term.

But yes, I mean what you said:

	You mean normal file system is faster than swap due to
	readahead and smart block of allocation ?

Yes.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
