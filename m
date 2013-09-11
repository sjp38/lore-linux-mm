Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7276D6B0033
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 10:39:24 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:39:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 07/16] slab: overloading the RCU head over the LRU for
 RCU free
In-Reply-To: <1377161065-30552-8-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <000001410d765d3a-0f3f8df2-dccb-455a-a929-f1fd018700d2-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-8-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> With build-time size checking, we can overload the RCU head over the LRU
> of struct page to free pages of a slab in rcu context. This really help to
> implement to overload the struct slab over the struct page and this
> eventually reduce memory usage and cache footprint of the SLAB.

Looks fine to me. Can you add the rcu_head to the struct page union? This
kind of overload is used frequently elsewhere as well. Then cleanup other
cases of such uses (such as in SLUB).

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
