Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 9E1486B0075
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:46:18 -0500 (EST)
Date: Tue, 15 Jan 2013 15:46:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] slub: correct to calculate num of acquired objects
 in get_partial_node()
In-Reply-To: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <0000013c3ee3b69a-80cfdc68-a753-44e0-ba68-511060864128-000000@email.amazonses.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 15 Jan 2013, Joonsoo Kim wrote:

> There is a subtle bug when calculating a number of acquired objects.
> After acquire_slab() is executed at first, page->inuse is same as
> page->objects, then, available is always 0. So, we always go next
> iteration.

page->inuse is always < page->objects because the partial list is not used
for slabs that are fully allocated. page->inuse == page->objects means
that no objects are available on the slab and therefore the slab would
have been removed from the partial list.

> After that, we don't need return value of put_cpu_partial().
> So remove it.

Hmmm... The code looks a bit easier to understand than what we have right now.

Could you try to explain it better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
