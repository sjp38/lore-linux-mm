Date: Wed, 16 Aug 2006 09:38:59 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Message-ID: <20060816053859.GC22921@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <1155558313.5696.167.camel@twins> <20060814123530.GA5019@2ka.mipt.ru> <1155639302.5696.210.camel@twins> <20060815112617.GB21736@2ka.mipt.ru> <1155643405.5696.236.camel@twins> <20060815123438.GA29896@2ka.mipt.ru> <1155649768.5696.262.camel@twins> <20060815141501.GA10998@2ka.mipt.ru> <20060815225237.03df7874.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20060815225237.03df7874.billfink@mindspring.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Fink <billfink@mindspring.com>
Cc: a.p.zijlstra@chello.nl, davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 15, 2006 at 10:52:37PM -0400, Bill Fink (billfink@mindspring.com) wrote:
> > Let's main system works only with TCP for simplicity.
> > Let's maximum allowed memory is limited by 1mb (it is 768k on machine
> > with 1gb of ram).
> 
> The maximum amount of memory available for TCP on a system with 1 GB
> of memory is 768 MB (not 768 KB).

It does not matter, let's it be 100mb or any other number, since
allocation is separated and does not depend on main system one.
Network allocator can steal pages from main one, but it does not suffer
from SLAB OOM.

Btw, I have a system with 1gb of ram and 1.5gb of low-mem tcp limit and
3gb of high-mem tcp memory limit calculated automatically.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
