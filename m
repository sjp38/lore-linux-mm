Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF8C56B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 16:38:23 -0400 (EDT)
Received: by wyb36 with SMTP id 36so11689277wyb.14
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 13:38:21 -0700 (PDT)
Subject: Re: [PATCH 03/10] Use percpu stats
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1009011501230.16013@router.home>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	 <1281374816-904-4-git-send-email-ngupta@vflare.org>
	 <alpine.DEB.2.00.1008301114460.10316@router.home>
	 <AANLkTikdhnr12uU8Wp60BygZwH770RBfxyfLNMzUsQje@mail.gmail.com>
	 <1283290106.2198.26.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1008311635100.867@router.home>
	 <1283290878.2198.28.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1009011501230.16013@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Sep 2010 22:38:15 +0200
Message-ID: <1283373495.2484.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Le mercredi 01 septembre 2010 A  15:05 -0500, Christoph Lameter a A(C)crit :

> The problem only exists on 32 bit platforms using 64 bit counters. If you
> would provide this functionality for the fallback case of 64 bit counters
> (here x86) in 32 bit arch code then you could use the this_cpu_*
> operations in all context without your special code being replicated in
> ohter places.
> 
> The additional advantage would be that for the 64bit case you would have
> much faster and more compact code.
> 
> 

My implementation is portable and use existing infrastructure, at the
time it was coded. BTW, its fast on 64bit too. As fast as previous
implementation. No extra code added. Please double check.

If you believe you can do better, please do so.

Of course, we added 64bit network stats to all 32bit arches only because
cost was acceptable. (I say all 32bit arches, because you seem to think
only x86 was the target)

Using this_cpu_{add|res}() fallback using atomic ops or spinlocks would
be slower than actual implemenation (smp_wmb() (nops on x86) and
increments).



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
