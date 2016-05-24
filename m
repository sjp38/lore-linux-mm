Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 318676B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 09:02:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 129so29270095pfx.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 06:02:09 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id m127si35920566pfb.124.2016.05.24.06.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 06:02:08 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id f8so2034698pag.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 06:02:08 -0700 (PDT)
Message-ID: <1464094926.5939.48.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH RESEND 8/8] af_unix: charge buffers to kmemcg
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 May 2016 06:02:06 -0700
In-Reply-To: <fcfe6cae27a59fbc5e40145664b3cf085a560c68.1464079538.git.vdavydov@virtuozzo.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
	 <fcfe6cae27a59fbc5e40145664b3cf085a560c68.1464079538.git.vdavydov@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, 2016-05-24 at 11:49 +0300, Vladimir Davydov wrote:
> Unix sockets can consume a significant amount of system memory, hence
> they should be accounted to kmemcg.
> 
> Since unix socket buffers are always allocated from process context,
> all we need to do to charge them to kmemcg is set __GFP_ACCOUNT in
> sock->sk_allocation mask.

I have two questions : 

1) What happens when a buffer, allocated from socket <A> lands in a
different socket <B>, maybe owned by another user/process.

Who owns it now, in term of kmemcg accounting ?

2) Has performance impact been evaluated ?

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
