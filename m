Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id A9B456B0256
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:51:27 -0400 (EDT)
Received: by lahg1 with SMTP id g1so56128948lah.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 05:51:26 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q9si3758608laj.173.2015.09.14.05.51.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 05:51:26 -0700 (PDT)
Date: Mon, 14 Sep 2015 15:51:11 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/3] memcg: drop unnecessary cold-path tests from
 __memcg_kmem_bypass()
Message-ID: <20150914125111.GF30743@esperanza>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
 <20150913201509.GE25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150913201509.GE25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Sun, Sep 13, 2015 at 04:15:09PM -0400, Tejun Heo wrote:
> __memcg_kmem_bypass() decides whether a kmem allocation should be
> bypassed to the root memcg.  Some conditions that it tests are valid
> criteria regarding who should be held accountable; however, there are
> a couple unnecessary tests for cold paths - __GFP_FAIL and
> fatal_signal_pending().
> 
> The previous patch updated try_charge() to handle both __GFP_FAIL and
> dying tasks correctly and the only thing these two tests are doing is
> making accounting less accurate and sprinkling tests for cold path
> conditions in the hot paths.  There's nothing meaningful gained by
> these extra tests.
> 
> This patch removes the two unnecessary tests from
> __memcg_kmem_bypass().
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
