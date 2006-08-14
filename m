Message-ID: <44E0B6E9.8050608@hp.com>
Date: Mon, 14 Aug 2006 10:46:17 -0700
From: Rick Jones <rick.jones2@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] network memory allocator.
References: <20060814110359.GA27704@2ka.mipt.ru>
In-Reply-To: <20060814110359.GA27704@2ka.mipt.ru>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Benchmarks with trivial epoll based web server showed noticeble (more
> than 40%) imrovements of the request rates (1600-1800 requests per
> second vs. more than 2300 ones). It can be described by more
> cache-friendly freeing algorithm, by tighter objects packing and thus
> reduced cache line ping-pongs, reduced lookups into higher-layer caches
> and so on.

Is that an hypothesis, or did you get a chance to gather cache stats 
with something like http://www.hp.com/go/Caliper or the like on the 
platform(s) you were testing?

rick jones

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
