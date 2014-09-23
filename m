Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 698046B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 03:26:15 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so4147544pde.8
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 00:26:15 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id v11si18954380pas.219.2014.09.23.00.26.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 00:26:14 -0700 (PDT)
Date: Tue, 23 Sep 2014 11:26:00 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 2/2] memcg: move memcg_update_cache_size to slab_common.c
Message-ID: <20140923072600.GB3588@esperanza>
References: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
 <0689062e28e13375241dcc64df2a398c9d606c64.1411054735.git.vdavydov@parallels.com>
 <20140922201137.GB5373@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140922201137.GB5373@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>

On Mon, Sep 22, 2014 at 04:11:37PM -0400, Johannes Weiner wrote:
> On Thu, Sep 18, 2014 at 07:50:20PM +0400, Vladimir Davydov wrote:
> > @@ -646,11 +646,13 @@ int memcg_limited_groups_array_size;
> >  struct static_key memcg_kmem_enabled_key;
> >  EXPORT_SYMBOL(memcg_kmem_enabled_key);
> >  
> > +static void memcg_free_cache_id(int id);
> 
> Any chance you could re-order this code to avoid the forward decl?

I'm going to move the call to memcg_free_cache_id() from the css free
path to css offline. Actually, this is what "[PATCH -mm 08/14] memcg:
release memcg_cache_id on css offline", which is a part of my "Per memcg
slab shrinkers" patch set, does. The css offline path is defined below
css_alloc/free_cache_id, so the forward declaration will be removed
then.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
