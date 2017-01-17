Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCAA6B0260
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:49:15 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so295006969pfx.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:49:15 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id b7si769556pli.5.2017.01.17.08.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 08:49:14 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id t6so4329160pgt.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 08:49:14 -0800 (PST)
Date: Tue, 17 Jan 2017 08:49:13 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET v2] slab: make memcg slab destruction scalable
Message-ID: <20170117164913.GB28948@mtj.duckdns.org>
References: <20170114184834.8658-1-tj@kernel.org>
 <20170117001256.GB25218@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117001256.GB25218@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hello,

On Tue, Jan 17, 2017 at 09:12:57AM +0900, Joonsoo Kim wrote:
> Could you confirm that your series solves the problem that is reported
> by Doug? It would be great if the result is mentioned to the patch
> description.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=172991

So, that's an issue in the creation path which is already resolved by
switching to an ordered workqueue (it'd probably be better to use
per-cpu wq w/ @max_active == 1 tho).  This patchset is about relesae
path.  slab_mutex contention would definitely go down with this but
I don't think there's more connection to it than that.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
