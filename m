Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C05FC6B026B
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 18:06:16 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x23-v6so1877321pln.11
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 15:06:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q14-v6sor1454664pff.56.2018.06.27.15.06.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 15:06:15 -0700 (PDT)
Subject: Re: [RFC PATCH] net, mm: account sock objects to kmemcg
References: <20180627204139.225988-1-shakeelb@google.com>
 <f08b2e2c-d4c6-7a80-10d9-104c0aab593b@gmail.com>
 <CALvZod4JTY8T19L-q+E1LLFVGFso6ea1MACKdFsed8dM-3AvYQ@mail.gmail.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <a48b2c73-b3b2-8291-202b-e5a2a5ee1f2a@gmail.com>
Date: Wed, 27 Jun 2018 15:06:13 -0700
MIME-Version: 1.0
In-Reply-To: <CALvZod4JTY8T19L-q+E1LLFVGFso6ea1MACKdFsed8dM-3AvYQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, eric.dumazet@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, davem@davemloft.net, Eric Dumazet <edumazet@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Linux MM <linux-mm@kvack.org>



On 06/27/2018 03:03 PM, Shakeel Butt wrote:

> 
> This will opt-in all the sock kmem_caches which I think is better and
> much smaller change. Should I resend this or do you want to send the
> patch?
>

Please send a V2, with maybe some updated changelog ;)

Thanks !
