Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2BE546B0087
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 12:13:20 -0500 (EST)
Date: Thu, 25 Nov 2010 09:13:13 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: Free memory never fully used, swapping
Message-ID: <20101125171313.GA15899@hostway.ca>
References: <1290647274.12777.3.camel@sli10-conroe> <20101125090328.GB14180@hostway.ca> <20101125191759.F465.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101125191759.F465.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 25, 2010 at 07:18:49PM +0900, KOSAKI Motohiro wrote:

> This?

> -	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> +	alloc_gfp = (flags | __GFP_NOWARN) & ~(__GFP_NOFAIL | __GFP_WAIT);

kswapd still gets woken in the !__GFP_WAIT case, which is what I was
seeing anyway, because the order-3 allocatons were starting from
__alloc_skb().

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
