Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 821AE6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 09:43:00 -0400 (EDT)
Date: Fri, 23 Aug 2013 13:42:59 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 05/16] slab: remove cachep in struct slab_rcu
In-Reply-To: <20130823065315.GG22605@lge.com>
Message-ID: <00000140ab69e6be-3b2999b6-93b4-4b22-a91f-8929aee5238f-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-6-git-send-email-iamjoonsoo.kim@lge.com> <00000140a72870a6-f7c87696-ecbc-432c-9f41-93f414c0c623-000000@email.amazonses.com> <20130823065315.GG22605@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 23 Aug 2013, Joonsoo Kim wrote:

> On Thu, Aug 22, 2013 at 05:53:00PM +0000, Christoph Lameter wrote:
> > On Thu, 22 Aug 2013, Joonsoo Kim wrote:
> >
> > > We can get cachep using page in struct slab_rcu, so remove it.
> >
> > Ok but this means that we need to touch struct page. Additional cacheline
> > in cache footprint.
>
> In following patch, we overload RCU_HEAD to LRU of struct page and
> also overload struct slab to struct page. So there is no
> additional cacheline footprint at final stage.

If you do not use rcu (standard case) then you have an additional
cacheline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
