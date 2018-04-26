Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36D5D6B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 09:47:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n78so18868827pfj.4
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 06:47:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g9sor4708629pgo.273.2018.04.26.06.47.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 06:47:55 -0700 (PDT)
Subject: Re: [PATCH v2 net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
References: <20180425214307.159264-1-edumazet@google.com>
 <20180425214307.159264-2-edumazet@google.com>
 <d3ad6970-4139-76a9-2417-3df077753aa9@oracle.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <0ab0c947-0c51-10b9-054c-7cbc5a1726bd@gmail.com>
Date: Thu, 26 Apr 2018 06:47:54 -0700
MIME-Version: 1.0
In-Reply-To: <d3ad6970-4139-76a9-2417-3df077753aa9@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ka-Cheong Poon <ka-cheong.poon@oracle.com>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>



On 04/26/2018 06:40 AM, Ka-Cheong Poon wrote:

> A quick question.A  Is it a normal practice to return a result
> in setsockopt() given that the optval parameter is supposed to
> be a const void *?

Very good question.

Andy suggested an ioctl() or setsockopt(), and I chose setsockopt() but it looks
like a better choice would have been getsockopt() indeed.

This might even allow future changes in "struct tcp_zerocopy_receive"

Willem suggested to add code in tcp_recvmsg() but I prefer to not bloat this already too complex function.

I will send a v3 using getsockopt() then, thanks !
