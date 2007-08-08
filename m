Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>
	<1186575947.3106.23.camel@castor.rsk.org>
From: Andi Kleen <andi@firstfloor.org>
Date: 08 Aug 2007 15:54:15 +0200
In-Reply-To: <1186575947.3106.23.camel@castor.rsk.org>
Message-ID: <p734pjarv20.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: richard kennedy <richard@rsk.demon.co.uk>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

richard kennedy <richard@rsk.demon.co.uk> writes:
> 
> This is on a standard desktop machine so there are lots of other
> processes running on it, and although there is a degree of variability
> in the numbers,they are very repeatable and your patch always out
> performs the stock mm2.
> looks good to me

iirc the goal of this is less to get better performance, but to avoid long user visible
latencies.  Of course if it's faster it's great too, but that's only secondary.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
