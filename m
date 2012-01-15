Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id DAFA56B004F
	for <linux-mm@kvack.org>; Sun, 15 Jan 2012 07:59:52 -0500 (EST)
Received: by eekc13 with SMTP id c13so141638eek.14
        for <linux-mm@kvack.org>; Sun, 15 Jan 2012 04:59:51 -0800 (PST)
Message-ID: <1326632384.11711.3.camel@lappy>
Subject: Re: Hung task when calling clone() due to netfilter/slab
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sun, 15 Jan 2012 14:59:44 +0200
In-Reply-To: <1326561043.5287.24.camel@edumazet-laptop>
References: <1326558605.19951.7.camel@lappy>
	 <1326561043.5287.24.camel@edumazet-laptop>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

On Sat, 2012-01-14 at 18:10 +0100, Eric Dumazet wrote:
> Apparently SLUB calls sysfs_slab_add() from kmem_cache_create() while
> still holding slub_lock.
> 
> So if the task launched needs to "cat /proc/slabinfo" or anything
> needing slub_lock, its a deadlock.

I've made the following patch to test it, It doesn't look like it's the correct solution, but it verifies that the problem is there (it works well with the patch).

---------------
