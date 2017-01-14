Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40A706B025E
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:39:12 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so187751002pfx.1
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:39:12 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id q17si16012232pgh.96.2017.01.14.07.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 07:39:11 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 204so1218391pge.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:39:11 -0800 (PST)
Date: Sat, 14 Jan 2017 10:39:08 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 6/9] slab: don't put memcg caches on slab_caches list
Message-ID: <20170114153908.GC32693@mtj.duckdns.org>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-7-tj@kernel.org>
 <20170114133918.GE2668@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114133918.GE2668@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 04:39:18PM +0300, Vladimir Davydov wrote:
> IIRC the slab_caches list is also used on cpu/mem online/offline, so you
> have to patch those places to ensure that memcg caches get updated too.
> Other than that the patch looks good to me.

Right, will update.  Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
