Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48BB96B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:13:59 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c5so9277693pfn.17
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 17:13:59 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id i11si2410811pfi.388.2018.02.26.17.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 17:13:57 -0800 (PST)
Date: Mon, 26 Feb 2018 20:13:55 -0500 (EST)
Message-Id: <20180226.201355.1546591469388453458.davem@davemloft.net>
Subject: Re: [PATCH 0/2] mark some slabs as visible not mergeable
From: David Miller <davem@davemloft.net>
In-Reply-To: <20180226134613.04edcc98@xeon-e3>
References: <20180224190454.23716-1-sthemmin@microsoft.com>
	<20180226.151502.1181392845403505211.davem@redhat.com>
	<20180226134613.04edcc98@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stephen@networkplumber.org
Cc: willy@infradead.org, netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, sthemmin@microsoft.com

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 26 Feb 2018 13:46:13 -0800

> This is ancient original iproute2 code that dumpster dives into
> slabinfo to get summary statistics on active objects.
> 
> 	1) open sockets (sock_inode_cache)

The sockets inuse counter from /proc/net/sockstat is really
sufficient for this.

> 	2) TCP ports bound (tcp_bind_buckets) [*]
> 	3) TCP time wait sockets (tw_sock_TCP) [*]

Time wait is provided by /proc/net/sockstat as well.

> 	4) TCP syn sockets (request_sock_TCP) [*]

It shouldn't be too hard to fill in the last two gaps, maintaining a
counter for bind buckets and request socks, and exporting them in new
/proc/net/sockstat field.

That would be so much better than disabling a useful optimization
in the SLAB allocator.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
