Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5799F6B026A
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 12:02:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t6so109758513pgt.6
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:02:18 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id u90si25488140pfk.38.2017.01.17.09.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 09:02:17 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 75so8460419pgf.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:02:17 -0800 (PST)
Date: Tue, 17 Jan 2017 09:02:15 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/9] slab: remove synchronous rcu_barrier() call in memcg
 cache release path
Message-ID: <20170117170215.GC28948@mtj.duckdns.org>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-3-tj@kernel.org>
 <20170114131939.GA2668@esperanza>
 <20170114151921.GA32693@mtj.duckdns.org>
 <20170117000754.GA25218@js1304-P5Q-DELUXE>
 <20170117163745.GA8352@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117163745.GA8352@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vladimir Davydov <vdavydov@tarantool.org>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 17, 2017 at 08:37:45AM -0800, Tejun Heo wrote:
> The call sequence doesn't matter.  Whether you're using call_rcu() or
> rcu_barrier(), you're just waiting for a grace period to pass before
> continuing.  It doens't give any other ordering guarantees, so the new
> code should be equivalent to the old one except for being asynchronous.

Oh I was confusing synchronize_rcu() with rcu_barrier(), so you're
right, kmem_cache struct needs to stay around for the slab pages to be
freed after RCU grace period.  Will revise the patch accordingly,
thanks.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
