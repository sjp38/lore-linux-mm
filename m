Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 233DA6B0070
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 10:04:25 -0500 (EST)
Date: Wed, 16 Jan 2013 15:04:23 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] slub: correct to calculate num of acquired objects
 in get_partial_node()
In-Reply-To: <20130116084114.GA13446@lge.com>
Message-ID: <0000013c43e3bb27-53587f7a-2c14-40a4-9ce9-a15dae10fc48-000000@email.amazonses.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com> <0000013c3ee3b69a-80cfdc68-a753-44e0-ba68-511060864128-000000@email.amazonses.com> <20130116084114.GA13446@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Jan 2013, Joonsoo Kim wrote:

> In acquire_slab() with mode = 1, we always set new.inuse = page->objects.

Yes with that we signal that we have extracted the objects from the slab.

> So
>
> 		acquire_slab(s, n, page, object == NULL);
>
>                 if (!object) {
>                         c->page = page;
>                         stat(s, ALLOC_FROM_PARTIAL);
>                         object = t;
>                         available =  page->objects - page->inuse;
>
> 			!!!!!! available is always 0 !!!!!!

Correct. We should really count the objects that we extracted in
acquire_slab(). Please update the description to the patch and repost.

Also it would be nice if we had some way to avoid passing a pointer to an
integer to acquire_slab. If we cannot avoid that then ok but it would be
nicer without that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
