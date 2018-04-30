Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6176B0005
	for <linux-mm@kvack.org>; Sun, 29 Apr 2018 21:34:21 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 106-v6so5804848otg.22
        for <linux-mm@kvack.org>; Sun, 29 Apr 2018 18:34:21 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id 63-v6si2245307otp.133.2018.04.29.18.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Apr 2018 18:34:19 -0700 (PDT)
Date: Sun, 29 Apr 2018 21:34:17 -0400 (EDT)
Message-Id: <20180429.213417.1622456092178936722.davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/2] tcp: mmap: rework zerocopy receive
From: David Miller <davem@davemloft.net>
In-Reply-To: <20180427155809.79094-1-edumazet@google.com>
References: <20180427155809.79094-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: edumazet@google.com
Cc: netdev@vger.kernel.org, luto@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ka-cheong.poon@oracle.com, eric.dumazet@gmail.com

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 27 Apr 2018 08:58:07 -0700

> syzbot reported a lockdep issue caused by tcp mmap() support.
> 
> I implemented Andy Lutomirski nice suggestions to resolve the
> issue and increase scalability as well.
> 
> First patch is adding a new getsockopt() operation and changes mmap()
> behavior.
> 
> Second patch changes tcp_mmap reference program.
> 
> v4: tcp mmap() support depends on CONFIG_MMU, as kbuild bot told us.
> 
> v3: change TCP_ZEROCOPY_RECEIVE to be a getsockopt() option
>     instead of setsockopt(), feedback from Ka-Cheon Poon
> 
> v2: Added a missing page align of zc->length in tcp_zerocopy_receive()
>     Properly clear zc->recv_skip_hint in case user request was completed.

Looks great, series applied, thanks Eric.
