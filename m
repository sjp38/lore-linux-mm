Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 66C636B00F2
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 15:11:01 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so12900060pad.29
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 12:11:01 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id az16si10239963pdb.218.2014.11.03.12.10.59
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 12:10:59 -0800 (PST)
Date: Mon, 03 Nov 2014 15:10:56 -0500 (EST)
Message-Id: <20141103.151056.1825096971313944324.davem@davemloft.net>
Subject: Re: [patch] mm: move page->mem_cgroup bad page handling into
 generic code fix
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141103182740.GA10816@phnom.home.cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
	<1414898156-4741-3-git-send-email-hannes@cmpxchg.org>
	<20141103182740.GA10816@phnom.home.cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, tj@kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 3 Nov 2014 13:27:40 -0500

> Remove unneeded !CONFIG_MEMCG memcg bad_page() dummies as well.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
