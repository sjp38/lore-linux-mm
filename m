Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DA6D66B01F4
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 19:23:03 -0400 (EDT)
Date: Wed, 28 Apr 2010 16:22:46 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] - Randomize node rotor used in
 cpuset_mem_spread_node()
Message-ID: <20100428162246.7e4632dc@nehalam>
In-Reply-To: <20100428161244.5d351395.akpm@linux-foundation.org>
References: <20100428131158.GA2648@sgi.com>
	<20100428150432.GA3137@sgi.com>
	<20100428154034.fb823484.akpm@linux-foundation.org>
	<1272495846.21962.1090.camel@calx>
	<20100428161244.5d351395.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Apr 2010 16:12:44 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

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

Because I need a cheap fast pseudo-random source for emulation
and it got used for more and more non-cryptographic uses.
And like most random generators people keep forgetting that
it was not intended for security use.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
