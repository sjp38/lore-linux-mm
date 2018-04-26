Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0755D6B0006
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:56:22 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v14so13387076pgq.11
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:56:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k63sor1049675pgc.245.2018.04.26.07.56.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 07:56:21 -0700 (PDT)
Subject: Re: [PATCH v2 net-next 0/2] tcp: mmap: rework zerocopy receive
References: <20180425214307.159264-1-edumazet@google.com>
 <CACSApvZF8CJqcRx7FGkMGitBiC6m0=_FT9XRZ=VV07U62wGM3Q@mail.gmail.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <a2c405e1-0ebc-dd33-fb0d-575bf06a1ff6@gmail.com>
Date: Thu, 26 Apr 2018 07:56:18 -0700
MIME-Version: 1.0
In-Reply-To: <CACSApvZF8CJqcRx7FGkMGitBiC6m0=_FT9XRZ=VV07U62wGM3Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soheil Hassas Yeganeh <soheil@google.com>, Eric Dumazet <edumazet@google.com>
Cc: "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>



On 04/25/2018 06:20 PM, Soheil Hassas Yeganeh wrote:
> 
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> 
>

Thanks Soheil for reviewing.

I have changed setsockopt() to getsockopt() so chose to not carry your Acked-by

Please add it back if you agree, thanks !
