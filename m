Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0E86B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 09:35:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l1so4386000pga.1
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 06:35:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g88si2985112pfk.65.2018.02.24.06.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 24 Feb 2018 06:35:22 -0800 (PST)
Date: Sat, 24 Feb 2018 06:35:20 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: tcp_bind_bucket is missing from slabinfo
Message-ID: <20180224143520.GA22222@bombadil.infradead.org>
References: <20180223225030.2e8ef122@shemminger-XPS-13-9360>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180223225030.2e8ef122@shemminger-XPS-13-9360>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 23, 2018 at 10:50:30PM -0800, Stephen Hemminger wrote:
> Somewhere back around 3.17 the kmem cache "tcp_bind_bucket" dropped out
> of /proc/slabinfo. It turns out the ss command was dumpster diving
> in slabinfo to determine the number of bound sockets and now it always
> reports 0.
> 
> Not sure why, the cache is still created but it doesn't
> show in slabinfo. Could it be some part of making slab/slub common code
> (or network namespaces). The cache is created in tcp_init but not visible.
> 
> Any ideas?

Try booting with slab_nomerge=1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
