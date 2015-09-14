Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6806B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 05:03:29 -0400 (EDT)
Received: by lbcjc2 with SMTP id jc2so63707947lbc.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 02:03:29 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id wq7si9048011lbc.105.2015.09.14.02.03.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 02:03:28 -0700 (PDT)
Date: Mon, 14 Sep 2015 12:03:13 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/3] memcg: collect kmem bypass conditions into
 __memcg_kmem_bypass()
Message-ID: <20150914090313.GC30743@esperanza>
References: <20150913201416.GC25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150913201416.GC25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Sun, Sep 13, 2015 at 04:14:16PM -0400, Tejun Heo wrote:
> memcg_kmem_newpage_charge() and memcg_kmem_get_cache() are testing the
> same series of conditions to decide whether to bypass kmem accounting.
> Collect the tests into __memcg_kmem_bypass().
> 
> This is pure refactoring.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
