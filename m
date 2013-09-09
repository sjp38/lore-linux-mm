Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7BD4F6B0033
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 00:32:20 -0400 (EDT)
Date: Mon, 9 Sep 2013 13:32:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [REPOST PATCH 1/4] slab: factor out calculate nr objects in
 cache_estimate
Message-ID: <20130909043233.GC22390@lge.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1378447067-19832-2-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140f3f56efb-1b2035a6-b81f-433f-aa2d-d1af50018b6a-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000140f3f56efb-1b2035a6-b81f-433f-aa2d-d1af50018b6a-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 06, 2013 at 03:48:04PM +0000, Christoph Lameter wrote:
> On Fri, 6 Sep 2013, Joonsoo Kim wrote:
> 
> >  	}
> >  	*num = nr_objs;
> > -	*left_over = slab_size - nr_objs*buffer_size - mgmt_size;
> > +	*left_over = slab_size - (nr_objs * buffer_size) - mgmt_size;
> >  }
> 
> What is the point of this change? Drop it.

Okay. I will drop it.

> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
