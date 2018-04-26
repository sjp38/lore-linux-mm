Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C48F86B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 21:21:22 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o66-v6so16380707iof.17
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 18:21:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 42-v6sor8337404ioh.93.2018.04.25.18.21.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 18:21:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180425214307.159264-1-edumazet@google.com>
References: <20180425214307.159264-1-edumazet@google.com>
From: Soheil Hassas Yeganeh <soheil@google.com>
Date: Wed, 25 Apr 2018 21:20:40 -0400
Message-ID: <CACSApvZF8CJqcRx7FGkMGitBiC6m0=_FT9XRZ=VV07U62wGM3Q@mail.gmail.com>
Subject: Re: [PATCH v2 net-next 0/2] tcp: mmap: rework zerocopy receive
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>

On Wed, Apr 25, 2018 at 5:43 PM, Eric Dumazet <edumazet@google.com> wrote:
> syzbot reported a lockdep issue caused by tcp mmap() support.
>
> I implemented Andy Lutomirski nice suggestions to resolve the
> issue and increase scalability as well.
>
> First patch is adding a new setsockopt() operation and changes mmap()
> behavior.
>
> Second patch changes tcp_mmap reference program.
>
> v2:
>  Added a missing page align of zc->length in tcp_zerocopy_receive()
>  Properly clear zc->recv_skip_hint in case user request was completed.

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Thank you Eric for the nice redesign!

> Eric Dumazet (2):
>   tcp: add TCP_ZEROCOPY_RECEIVE support for zerocopy receive
>   selftests: net: tcp_mmap must use TCP_ZEROCOPY_RECEIVE
>
>  include/uapi/linux/tcp.h               |   8 ++
>  net/ipv4/tcp.c                         | 189 +++++++++++++------------
>  tools/testing/selftests/net/tcp_mmap.c |  63 +++++----
>  3 files changed, 142 insertions(+), 118 deletions(-)
>
> --
> 2.17.0.441.gb46fe60e1d-goog
>
