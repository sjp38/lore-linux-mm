Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D8BE76B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 12:18:58 -0500 (EST)
Received: by wicr5 with SMTP id r5so1487593wic.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 09:18:57 -0800 (PST)
Message-ID: <1326561533.5287.26.camel@edumazet-laptop>
Subject: Re: Hung task when calling clone() due to netfilter/slab
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 14 Jan 2012 18:18:53 +0100
In-Reply-To: <1326561043.5287.24.camel@edumazet-laptop>
References: <1326558605.19951.7.camel@lappy>
	 <1326561043.5287.24.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

Le samedi 14 janvier 2012 A  18:10 +0100, Eric Dumazet a A(C)crit :

> Apparently SLUB calls sysfs_slab_add() from kmem_cache_create() while
> still holding slub_lock.
> 
> So if the task launched needs to "cat /proc/slabinfo" or anything
> needing slub_lock, its a deadlock.
> 
> 

Bug added in commit 2bce64858442149784f6c88
(slub: Allow removal of slab caches during boot)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
