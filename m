Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 03B556B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 17:35:25 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id n128so30455577pfn.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 14:35:24 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id kh7si4738871pab.85.2016.01.21.14.35.23
        for <linux-mm@kvack.org>;
        Thu, 21 Jan 2016 14:35:23 -0800 (PST)
Date: Thu, 21 Jan 2016 14:17:33 -0800 (PST)
Message-Id: <20160121.141733.2205727468476098690.davem@davemloft.net>
Subject: Re: [PATCH] net: sock: remove dead cgroup methods from struct proto
From: David Miller <davem@davemloft.net>
In-Reply-To: <20160121205628.GA14909@cmpxchg.org>
References: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
	<56A131D7.4040102@cogentembedded.com>
	<20160121205628.GA14909@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 21 Jan 2016 15:56:28 -0500

> From ac0fd0c5f31cdc73c52fd86f40af419c1871fbcf Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 21 Jan 2016 13:34:47 -0500
> Subject: [PATCH] net: sock: remove dead cgroup methods from struct proto
> 
> The cgroup methods are no longer used after baac50bbc3cd ("net:
> tcp_memcontrol: simplify linkage between socket and page counter").
> The hunk to delete them was included in the original patch but must
> have gotten lost during conflict resolution on the way upstream.
> 
> Fixes: baac50bbc3cd ("net: tcp_memcontrol: simplify linkage between socket and page counter")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Applied, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
