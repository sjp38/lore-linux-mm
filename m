Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 490186B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:28:23 -0500 (EST)
Received: by pfdd184 with SMTP id d184so14363571pfd.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:28:23 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id t74si6125470pfa.170.2015.12.08.08.28.22
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 08:28:22 -0800 (PST)
Date: Tue, 08 Dec 2015 11:28:20 -0500 (EST)
Message-Id: <20151208.112820.1456343214602612286.davem@davemloft.net>
Subject: Re: [PATCH 14/14] mm: memcontrol: switch to the updated jump-label
 API
From: David Miller <davem@davemloft.net>
In-Reply-To: <1449588624-9220-15-git-send-email-hannes@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
	<1449588624-9220-15-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue,  8 Dec 2015 10:30:24 -0500

> According to <linux/jump_label.h> the direct use of struct static_key
> is deprecated. Update the socket and slab accounting code accordingly.
> 
> Reported-by: Jason Baron <jbaron@akamai.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
