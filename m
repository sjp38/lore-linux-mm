Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5CC496B0074
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 12:40:57 -0500 (EST)
Date: Tue, 22 Nov 2011 11:40:48 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: Lockout validation scans during freeing of object
In-Reply-To: <1321982484.18002.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1111221139240.28197@router.home>
References: <alpine.DEB.2.00.1111221033350.28197@router.home>  <alpine.DEB.2.00.1111221040300.28197@router.home>  <alpine.DEB.2.00.1111221052130.28197@router.home> <1321982484.18002.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, 22 Nov 2011, Eric Dumazet wrote:

> This seems better, but I still have some warnings :

Trying to reproduce with a kernel configured to do preempt. This is
actually quite interesting since its always off by 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
