Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 45F736B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 16:52:01 -0400 (EDT)
Date: Thu, 19 May 2011 15:51:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] kernel buffer overflow kmalloc_slab() fix
In-Reply-To: <1305834712-27805-2-git-send-email-james_p_freyensee@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1105191550001.12530@router.home>
References: <james_p_freyensee@linux.intel.com> <1305834712-27805-2-git-send-email-james_p_freyensee@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: james_p_freyensee@linux.intel.com
Cc: linux-mm@kvack.org, gregkh@suse.de, hari.k.kanigeri@intel.com

On Thu, 19 May 2011, james_p_freyensee@linux.intel.com wrote:

> From: J Freyensee <james_p_freyensee@linux.intel.com>
>
> Currently, kmalloc_index() can return -1, which can be
> passed right to the kmalloc_caches[] array, cause a

No kmalloc_index() cannot return -1 for the use case that you are
considering here. The value passed as a size to
kmalloc_slab is bounded by 2 * PAGE_SIZE and kmalloc_slab will only return
-1 for sizes > 4M. So we will have to get machines with page sizes > 2M
before this can be triggered.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
