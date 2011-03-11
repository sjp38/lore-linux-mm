Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EBC8A8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 10:15:45 -0500 (EST)
Date: Fri, 11 Mar 2011 09:15:42 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: COW userspace memory mapping question
In-Reply-To: <474da85b78a7bd1e16726b72e9162f5c@anilinux.org>
Message-ID: <alpine.DEB.2.00.1103110914290.18585@router.home>
References: <056c7b49e7540a910b8a4f664415e638@anilinux.org> <alpine.DEB.2.00.1103101309090.2161@router.home> <faf1c53253ae791c39448de707b96c15@anilinux.org> <alpine.DEB.2.00.1103101532230.2161@router.home> <474da85b78a7bd1e16726b72e9162f5c@anilinux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mordae <mordae@anilinux.org>
Cc: linux-mm@kvack.org

On Thu, 10 Mar 2011, Mordae wrote:

> On Thu, 10 Mar 2011 15:33:31 -0600 (CST), Christoph Lameter <cl@linux.com>
> wrote:
> > First establish an RW mapping of the file.
> > Then -- when you want to take the snapshot -- unmap it and do two mmaps
> to
> > the old and new location. Make both readonly and MAP_PRIVATE. That will
> > cause the kernel to create readonly pages that are subject to COW.
>
> I see, that seems reasonable. But what if I was picky and want to snapshot
> that piece of memory continuously? Let's say once in several minutes, then
> let some thread to do stuffs to the original using consistent information
> from the snapshot.

Keep the RW mapping around and tear down and repeat the MAP_PRIVATE mmaps
areas as needed? Updates would have to be done to the RW mapping.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
