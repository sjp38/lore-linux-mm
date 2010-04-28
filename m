Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 755D76B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 19:28:10 -0400 (EDT)
Subject: Re: [PATCH v2] - Randomize node rotor used in
 cpuset_mem_spread_node()
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20100428161244.5d351395.akpm@linux-foundation.org>
References: <20100428131158.GA2648@sgi.com> <20100428150432.GA3137@sgi.com>
	 <20100428154034.fb823484.akpm@linux-foundation.org>
	 <1272495846.21962.1090.camel@calx>
	 <20100428161244.5d351395.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Apr 2010 18:28:05 -0500
Message-ID: <1272497285.21962.1110.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-04-28 at 16:12 -0700, Andrew Morton wrote:
> On Wed, 28 Apr 2010 18:04:06 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > > I suspect random32() would suffice here.  It avoids depleting the
> > > entropy pool altogether.
> > 
> > I wouldn't worry about that. get_random_int() touches the urandom pool,
> > which will always leave entropy around. Also, Ted and I decided over a
> > year ago that we should drop the whole entropy accounting framework,
> > which I'll get around to some rainy weekend.
> 
> hm, so why does random32() exist?  Speed?

Yep. There are lots of RNG uses that aren't security sensitive and this
is one: the kernel won't be DoSed by an attacker that gets all pages
preferentially allocated on one node. Performance will suffer, but it's
reasonably bounded.

One of my goals is to call these sorts of trade-offs out in the API, ie:

get_fast_random_u32()
get_fast_random_bytes()
get_secure_random_u32()
get_secure_random_bytes()

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
