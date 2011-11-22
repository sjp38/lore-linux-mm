Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 54ABB6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:43:01 -0500 (EST)
Date: Mon, 21 Nov 2011 16:42:47 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
Message-ID: <alpine.DEB.2.01.1111211638140.8000@trent.utfs.org>
References: <20111121131531.GA1679@x4.trippels.de>  <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121153621.GA1678@x4.trippels.de>  <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121161036.GA1679@x4.trippels.de>
  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121173556.GA1673@x4.trippels.de>  <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121185215.GA1673@x4.trippels.de>
  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop> <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Mon, 21 Nov 2011 at 16:21, Christian Kujau wrote:
> With debug options enabled I'm currently in the xmon debugger, not sure 
> what to make of it yet, I'll try to get something useful out of it :)

Only screenshots, see the *xmon jpegs in:

   http://nerdbynature.de/bits/3.2.0-rc1/oops/

> SLAB does not have the same capabilities to detect corruption.
> You can disable most the cpu partial functionality by setting
>       /sys/kernel/slab/*/cpu_partial
> to 0

I'll try to reproduce with those set to 0 (I'm on UP here, in case that 
matters).

Thanks,
Christian.
-- 
BOFH excuse #296:

The hardware bus needs a new token.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
