Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 1B8D46B006E
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 14:10:45 -0400 (EDT)
Date: Wed, 1 Aug 2012 13:10:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Any reason to use put_page in slub.c?
In-Reply-To: <50192453.9080706@parallels.com>
Message-ID: <alpine.DEB.2.00.1208011307450.4606@router.home>
References: <1343391586-18837-1-git-send-email-glommer@parallels.com>  <alpine.DEB.2.00.1207271054230.18371@router.home>  <50163D94.5050607@parallels.com>  <alpine.DEB.2.00.1207301421150.27584@router.home>  <5017968C.6050301@parallels.com>
 <alpine.DEB.2.00.1207310906350.32295@router.home>  <5017E72D.2060303@parallels.com>  <alpine.DEB.2.00.1207310915150.32295@router.home>  <5017E929.70602@parallels.com>  <alpine.DEB.2.00.1207310927420.32295@router.home> <1343746344.8473.4.camel@dabdike.int.hansenpartnership.com>
 <50192453.9080706@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 1 Aug 2012, Glauber Costa wrote:

> I've audited all users of get_page() in the drivers/ directory for
> patterns like this. In general, they kmalloc something like a table of
> entries, and then get_page() the entries. The entries are either user
> pages, pages allocated by the page allocator, or physical addresses
> through their pfn (in 2 cases from the vga ones...)
>
> I took a look about some other instances where virt_to_page occurs
> together with kmalloc as well, and they all seem to fall in the same
> category.

The case that was notorious in the past was a scsi control structure
allocated from slab that was then written to the device via DMA. And it
was not on x86 but some esoteric platform (powerpc?),

A reference to the discussion of this issue in 2007:

http://lkml.indiana.edu/hypermail/linux/kernel/0706.3/0424.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
