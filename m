Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 55F278D0040
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 14:38:04 -0400 (EDT)
Date: Sun, 3 Apr 2011 13:38:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: kernel BUG at mm/slub.c:1193!
In-Reply-To: <201104012359.58676.johannes.hirte@fem.tu-ilmenau.de>
Message-ID: <alpine.DEB.2.00.1104031336250.15317@router.home>
References: <201104012053.30458.johannes.hirte@fem.tu-ilmenau.de> <alpine.DEB.2.00.1104011625550.27326@router.home> <201104012359.58676.johannes.hirte@fem.tu-ilmenau.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 1 Apr 2011, Johannes Hirte wrote:

> On Friday 01 April 2011 23:28:02 Christoph Lameter wrote:
> > Which kernel version is this? Line 1193 in upstream is not in the function
> > new_slab(). If this is the BUG_ON in new_slab() then we have an issue with
> > illegal flags being passed to kmem_cache_alloc().
>
> As the Oops says, it is 2.6.38.1. This is the BUG_ON in new_slab().

Well you need to talk to the one who wrote the passed illegal flags to
kmem_cache_alloc. Would be helpful to know which flags were passed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
