Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 106636B0003
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 11:36:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u65so7041119pfd.7
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 08:36:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor1814054pfb.52.2018.02.25.08.36.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Feb 2018 08:36:46 -0800 (PST)
Date: Sun, 25 Feb 2018 08:36:44 -0800
From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/2] mark some slabs as visible not mergeable
Message-ID: <20180225083644.1707c8b0@xeon-e3>
In-Reply-To: <20180224190454.23716-1-sthemmin@microsoft.com>
References: <20180224190454.23716-1-sthemmin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, willy@infradead.org
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, Stephen Hemminger <sthemmin@microsoft.com>

On Sat, 24 Feb 2018 11:04:52 -0800
Stephen Hemminger <stephen@networkplumber.org> wrote:

> This fixes an old bug in iproute2's ss command because it was
> reading slabinfo to get statistics. There isn't a better API
> to do this, and one can argue that /proc is a UAPI that must
> not change.
> 
> Therefore this patch set adds a flag to slab to give another
> reason to prevent merging, and then uses it in network code.
> 
> The patches are against davem's linux-net tree and should also
> goto stable as well.
> 
> Stephen Hemminger (2):
>   slab: add flag to block merging of UAPI elements
>   net: mark slab's used by ss as UAPI
> 
>  include/linux/slab.h | 6 ++++++
>  mm/slab_common.c     | 2 +-
>  net/ipv4/tcp.c       | 3 ++-
>  net/ipv4/tcp_ipv4.c  | 2 +-
>  net/ipv6/tcp_ipv6.c  | 2 +-
>  net/socket.c         | 6 +++---
>  6 files changed, 14 insertions(+), 7 deletions(-)
> 

The kbuild reports need more root cause investigation before applying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
