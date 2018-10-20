Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE0A6B0003
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 11:37:48 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id x5-v6so33604356ioa.6
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 08:37:48 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b1-v6si17082711jae.32.2018.10.20.08.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 20 Oct 2018 08:37:46 -0700 (PDT)
Subject: Re: Memory management issue in 4.18.15
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a655c898-0701-f10d-bbf3-8a0090544560@infradead.org>
Date: Sat, 20 Oct 2018 08:37:28 -0700
MIME-Version: 1.0
In-Reply-To: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Spock <dairinin@gmail.com>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Rik van Riel <riel@surriel.com>, Sasha Levin <alexander.levin@microsoft.com>

[add linux-mm mailing list + people]


On 10/20/18 4:41 AM, Spock wrote:
> Hello,
> 
> I have a workload, which creates lots of cache pages. Before 4.18.15,
> the behavior was very stable: pagecache is constantly growing until it
> consumes all the free memory, and then kswapd is balancing it around
> low watermark. After 4.18.15, once in a while khugepaged is waking up
> and reclaims almost all the pages from pagecache, so there is always
> around 2G of 8G unused. THP is enabled only for madvise case and are
> not used.
> 
> The exact change that leads to current behavior is
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=linux-4.18.y&id=62aad93f09c1952ede86405894df1b22012fd5ab
> 


-- 
~Randy
