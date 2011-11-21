Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AF51C6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 16:43:31 -0500 (EST)
Date: Mon, 21 Nov 2011 15:43:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <CAOJsxLGLZ23momLxidvhC+2LCtmnwmPMS2ASdke8V8gGFGa=AA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111211539420.10548@router.home>
References: <20111121131531.GA1679@x4.trippels.de> <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121153621.GA1678@x4.trippels.de> <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121161036.GA1679@x4.trippels.de>
 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121173556.GA1673@x4.trippels.de> <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111121185215.GA1673@x4.trippels.de>
 <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop> <CAOJsxLGLZ23momLxidvhC+2LCtmnwmPMS2ASdke8V8gGFGa=AA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christian Kujau <lists@nerdbynature.de>

On Mon, 21 Nov 2011, Pekka Enberg wrote:

> Does CONFIG_SLAB make all the issues go away or are you still able to
> reproduce corruption with it? I'm asking because we have the per-cpu
> partial list patches in 3.2-rc1 and I'd like to rule them out as a
> suspect.

SLAB does not have the same capabilities to detect corruption.

You can disable most the cpu partial functionality by setting

	/sys/kernel/slab/*/cpu_partial

to 0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
