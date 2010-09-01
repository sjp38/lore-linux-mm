Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 27E566B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 16:06:03 -0400 (EDT)
Date: Wed, 1 Sep 2010 15:05:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 03/10] Use percpu stats
In-Reply-To: <1283290878.2198.28.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1009011501230.16013@router.home>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>  <1281374816-904-4-git-send-email-ngupta@vflare.org>  <alpine.DEB.2.00.1008301114460.10316@router.home>  <AANLkTikdhnr12uU8Wp60BygZwH770RBfxyfLNMzUsQje@mail.gmail.com>  <1283290106.2198.26.camel@edumazet-laptop>
  <alpine.DEB.2.00.1008311635100.867@router.home> <1283290878.2198.28.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2010, Eric Dumazet wrote:

> > > Even for single counter, this_cpu_read(64bit) is not using an RMW
> > > (cmpxchg8) instruction, so you can get very strange results when low
> > > order 32bit wraps.
> >
> > How about fixing it so that everyone benefits?
> >
>
> IMHO, this_cpu_read() is fine as is : a _read_ operation.
>
> Dont pretend it can be used in every context, its not true.

The problem only exists on 32 bit platforms using 64 bit counters. If you
would provide this functionality for the fallback case of 64 bit counters
(here x86) in 32 bit arch code then you could use the this_cpu_*
operations in all context without your special code being replicated in
ohter places.

The additional advantage would be that for the 64bit case you would have
much faster and more compact code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
