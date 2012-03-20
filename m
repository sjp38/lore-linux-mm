Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 554A16B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 11:15:08 -0400 (EDT)
Date: Tue, 20 Mar 2012 10:15:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 6/6] workqueue: use kmalloc_align() instead of
 hacking
In-Reply-To: <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1203201014030.19333@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 20 Mar 2012, Lai Jiangshan wrote:

> kmalloc_align() makes the code simpler.

Another approach would be to simply create a new slab cache using
kmem_cache_create() with the desired alignment and allocate from
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
