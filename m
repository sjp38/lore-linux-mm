Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 4A1386B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 12:04:23 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1141890pbc.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:04:22 -0700 (PDT)
Subject: Re: Patch workqueue: create new slab cache instead of hacking
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1203210959500.21932@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
	 <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com>
	 <20120320154619.GA5684@google.com> <4F6944D9.5090002@cn.fujitsu.com>
	 <CAOS58YPydFUap4HjuRATxza6VZgyrXmQHVxR83G7GRJL50ZTRQ@mail.gmail.com>
	 <alpine.DEB.2.00.1203210910450.20482@router.home>
	 <1332341381.7893.17.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1203210959500.21932@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Mar 2012 09:04:19 -0700
Message-ID: <1332345859.5330.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2012-03-21 at 10:03 -0500, Christoph Lameter wrote:
> On Wed, 21 Mar 2012, Eric Dumazet wrote:
> 
> > Creating a dedicated cache for few objects ? Thats a lot of overhead, at
> > least for SLAB (no merges of caches)
> 
> Its some overhead for SLAB (a lot is what? If you tune down the per cpu
> caches it should be a couple of pages) but its none for SLUB.

SLAB overhead per cache is O(CPUS * nr_node_ids)  (unless alien caches
are disabled)

For few in flight objects, its just better to use standard kmalloc-xxxx
caches.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
