Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 632BC6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 12:31:34 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id rp18so14081735iec.14
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 09:31:34 -0700 (PDT)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id wa16si7339781icb.86.2014.09.26.09.31.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 09:31:33 -0700 (PDT)
Date: Fri, 26 Sep 2014 11:31:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/4] slab: fix cpuset check in fallback_alloc
In-Reply-To: <5ccdd901946feaf88fd6d2441b18a6845cc56571.1411741632.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1409261130550.3870@gentwo.org>
References: <cover.1411741632.git.vdavydov@parallels.com> <5ccdd901946feaf88fd6d2441b18a6845cc56571.1411741632.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, 26 Sep 2014, Vladimir Davydov wrote:

> To avoid this we should use softwall cpuset check in fallback_alloc.

Its weird that softwall checking occurs by setting __GFP_HARDWALL.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  mm/slab.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index eb6f0cf6875c..e35822d07821 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3051,7 +3051,7 @@ retry:
>  	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>  		nid = zone_to_nid(zone);
>
> -		if (cpuset_zone_allowed(zone, flags | __GFP_HARDWALL) &&
> +		if (cpuset_zone_allowed(zone, flags) &&
>  			get_node(cache, nid) &&
>  			get_node(cache, nid)->free_objects) {
>  				obj = ____cache_alloc_node(cache,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
