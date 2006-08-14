Date: Mon, 14 Aug 2006 23:42:01 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Message-ID: <20060814194201.GA10747@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <44E0B6E9.8050608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <44E0B6E9.8050608@hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rick Jones <rick.jones2@hp.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 14, 2006 at 10:46:17AM -0700, Rick Jones (rick.jones2@hp.com) wrote:
> >Benchmarks with trivial epoll based web server showed noticeble (more
> >than 40%) imrovements of the request rates (1600-1800 requests per
> >second vs. more than 2300 ones). It can be described by more
> >cache-friendly freeing algorithm, by tighter objects packing and thus
> >reduced cache line ping-pongs, reduced lookups into higher-layer caches
> >and so on.
> 
> Is that an hypothesis, or did you get a chance to gather cache stats 
> with something like http://www.hp.com/go/Caliper or the like on the 
> platform(s) you were testing?

It is theory based on code observation, design comparison and logic.

> rick jones

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
