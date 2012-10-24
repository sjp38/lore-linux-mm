Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 80DB06B006E
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 04:58:39 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so204753lag.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 01:58:37 -0700 (PDT)
Date: Wed, 24 Oct 2012 11:58:33 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 1/2] slab: commonize slab_cache field in struct page
In-Reply-To: <1350914737-4097-2-git-send-email-glommer@parallels.com>
Message-ID: <alpine.LFD.2.02.1210241158190.13035@tux.localdomain>
References: <1350914737-4097-1-git-send-email-glommer@parallels.com> <1350914737-4097-2-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Mon, 22 Oct 2012, Glauber Costa wrote:
> Right now, slab and slub have fields in struct page to derive which
> cache a page belongs to, but they do it slightly differently.
> 
> slab uses a field called slab_cache, that lives in the third double
> word. slub, uses a field called "slab", living outside of the
> doublewords area.
> 
> Ideally, we could use the same field for this. Since slub heavily makes
> use of the doubleword region, there isn't really much room to move
> slub's slab_cache field around. Since slab does not have such strict
> placement restrictions, we can move it outside the doubleword area.
> 
> The naming used by slab, "slab_cache", is less confusing, and it is
> preferred over slub's generic "slab".
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@kernel.org>
> CC: David Rientjes <rientjes@google.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
