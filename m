Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6308D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 17:11:53 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Date: Thu, 10 Mar 2011 23:11:45 +0100
From: Mordae <mordae@anilinux.org>
In-Reply-To: <alpine.DEB.2.00.1103101532230.2161@router.home>
References: <056c7b49e7540a910b8a4f664415e638@anilinux.org> <alpine.DEB.2.00.1103101309090.2161@router.home> <faf1c53253ae791c39448de707b96c15@anilinux.org> <alpine.DEB.2.00.1103101532230.2161@router.home>
Message-ID: <474da85b78a7bd1e16726b72e9162f5c@anilinux.org>
Subject: Re: COW userspace memory mapping question
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

On Thu, 10 Mar 2011 15:33:31 -0600 (CST), Christoph Lameter <cl@linux.com>
wrote:
> First establish an RW mapping of the file.
> Then -- when you want to take the snapshot -- unmap it and do two mmaps
to
> the old and new location. Make both readonly and MAP_PRIVATE. That will
> cause the kernel to create readonly pages that are subject to COW.

I see, that seems reasonable. But what if I was picky and want to snapshot
that piece of memory continuously? Let's say once in several minutes, then
let some thread to do stuffs to the original using consistent information
from the snapshot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
