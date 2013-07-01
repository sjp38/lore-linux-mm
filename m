Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 76D416B0033
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 14:19:44 -0400 (EDT)
Date: Mon, 1 Jul 2013 18:19:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slab: Drop unnecessary slabp->inuse < cachep->num
 test
In-Reply-To: <51D1AE84.8010404@gmail.com>
Message-ID: <0000013f9b76364e-6d24303e-93bc-425d-9933-710b0587b56b-000000@email.amazonses.com>
References: <51D1AE84.8010404@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: penberg@kernel.org, mpm@selenic.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Tue, 2 Jul 2013, Zhang Yanfei wrote:

> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>
> In function cache_alloc_refill, we have used BUG_ON to ensure
> that slabp->inuse is less than cachep->num before the while
> test. And in the while body, we do not change the value of
> slabp->inuse and cachep->num, so it is not necessary to test
> if slabp->inuse < cachep->num test for every loop.

The body calls slab_get_obj which changes slabp->inuse!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
