Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 0C51F6B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 09:55:36 -0400 (EDT)
Date: Wed, 5 Sep 2012 13:55:35 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix the DEADLOCK issue on l3 alien lock
In-Reply-To: <5046B9EE.7000804@linux.vnet.ibm.com>
Message-ID: <0000013996b6f21d-d45be653-3111-4aef-b079-31dc673e6fd8-000000@email.amazonses.com>
References: <5044692D.7080608@linux.vnet.ibm.com> <5046B9EE.7000804@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 5 Sep 2012, Michael Wang wrote:

> Since the cachep and cachep->slabp_cache's l3 alien are in the same lock class,
> fake report generated.

Ahh... That is a key insight into why this occurs.

> This should not happen since we already have init_lock_keys() which will
> reassign the lock class for both l3 list and l3 alien.

Right. I was wondering why we still get intermitted reports on this.

> This patch will invoke init_lock_keys() after we done enable_cpucache()
> instead of before to avoid the fake DEADLOCK report.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
