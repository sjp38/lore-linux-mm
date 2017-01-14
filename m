Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAF0E6B0260
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:39:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so187756211pfb.7
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:39:37 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id l3si16035997pld.52.2017.01.14.07.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 07:39:37 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 19so702151pfo.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:39:36 -0800 (PST)
Date: Sat, 14 Jan 2017 10:39:34 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 7/9] slab: introduce __kmemcg_cache_deactivate()
Message-ID: <20170114153934.GD32693@mtj.duckdns.org>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-8-tj@kernel.org>
 <20170114134211.GF2668@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114134211.GF2668@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 04:42:11PM +0300, Vladimir Davydov wrote:
> > +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> > +void __kmemcg_cache_deactivate(struct kmem_cache *s);
> > +#endif
> 
> nit: ifdef is not necessary

Will drop, thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
