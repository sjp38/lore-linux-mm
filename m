Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 366536B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 12:43:50 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id z143so26055313ywz.7
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 09:43:50 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id z187si7455008ywe.456.2017.02.03.09.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 09:43:49 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id l16so2275510ywb.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 09:43:49 -0800 (PST)
Date: Fri, 3 Feb 2017 12:43:46 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET v3] slab: make memcg slab destruction scalable
Message-ID: <20170203174346.GA26336@mtj.duckdns.org>
References: <20170117235411.9408-1-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117235411.9408-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hello,

On Tue, Jan 17, 2017 at 03:54:01PM -0800, Tejun Heo wrote:
> Changes from [V2] to V3.
> 
> * 0002-slub-separate-out-sysfs_slab_release-from-sysfs_slab.patch
>   separated out from
>   0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch.
> 
> * 0002-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch
>   replaced with
>   0003-slab-remove-synchronous-rcu_barrier-call-in-memcg-ca.patch.
>   It now keeps rcu_barrier() in the kmem_cache destruction path.
> 
> * 0010-slab-memcg-wq.patch added to limit concurrency on destruction
>   work items.

Are there more concerns on this patchset?  If not, Andrew, can you
please route these patches?  On certain setups, this can cause serious
performance and scalability issues.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
