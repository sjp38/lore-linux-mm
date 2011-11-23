Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D439D6B00AB
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 18:16:01 -0500 (EST)
Received: by iaek3 with SMTP id k3so2917236iae.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 15:16:00 -0800 (PST)
Date: Wed, 23 Nov 2011 15:15:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: use irqsafe_cpu_cmpxchg for put_cpu_partial
In-Reply-To: <alpine.DEB.2.00.1111230907330.16139@router.home>
Message-ID: <alpine.DEB.2.00.1111231515250.24794@chino.kir.corp.google.com>
References: <20111121131531.GA1679@x4.trippels.de> <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121161036.GA1679@x4.trippels.de> <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121173556.GA1673@x4.trippels.de> <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121185215.GA1673@x4.trippels.de> <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop> <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
 <alpine.DEB.2.00.1111212105330.19606@router.home> <1321948113.27077.24.camel@edumazet-laptop> <1321999085.14573.2.camel@pasglop> <alpine.DEB.2.01.1111221511070.8000@trent.utfs.org> <1322007501.14573.15.camel@pasglop> <alpine.DEB.2.01.1111222145470.8000@trent.utfs.org>
 <CAOJsxLGWTRuwQ04Mg26fNhZEmo7yVXG5vSZgF7Q5GESCk65odA@mail.gmail.com> <alpine.DEB.2.00.1111230907330.16139@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Eric Dumazet <eric.dumazet@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, "Alex,Shi" <alex.shi@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>

On Wed, 23 Nov 2011, Christoph Lameter wrote:

> Subject: slub: use irqsafe_cpu_cmpxchg for put_cpu_partial
> 
> The cmpxchg must be irq safe. The fallback for this_cpu_cmpxchg only
> disables preemption which results in per cpu partial page operation
> potentially failing on non x86 platforms.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
