Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8EE616B006C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 10:07:32 -0500 (EST)
Date: Tue, 22 Nov 2011 09:07:27 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <alpine.DEB.2.00.1111220900330.25785@router.home>
Message-ID: <alpine.DEB.2.00.1111220907050.25785@router.home>
References: <20111121161036.GA1679@x4.trippels.de>   <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <20111121173556.GA1673@x4.trippels.de>   <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
  <20111121185215.GA1673@x4.trippels.de>   <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>   <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>   <alpine.DEB.2.00.1111212105330.19606@router.home>   <20111122084513.GA1688@x4.trippels.de>
  <1321954729.2474.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1321955185.2474.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <alpine.DEB.2.00.1111220844400.25785@router.home> <1321973567.2474.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1111220900330.25785@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1111220907052.25785@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, 22 Nov 2011, Christoph Lameter wrote:

> Not sure what the solution is but the simplest would be to disable
> validation if lockless is active.

That is already being done so you must have run the validation with
debugging on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
