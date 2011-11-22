Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DE23E6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:52:51 -0500 (EST)
Received: by ywp17 with SMTP id 17so319592ywp.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 06:52:51 -0800 (PST)
Message-ID: <1321973567.2474.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2011 15:52:47 +0100
In-Reply-To: <alpine.DEB.2.00.1111220844400.25785@router.home>
References: <20111121161036.GA1679@x4.trippels.de>
	  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <20111121173556.GA1673@x4.trippels.de>
	  <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>
	  <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	  <alpine.DEB.2.00.1111212105330.19606@router.home>
	  <20111122084513.GA1688@x4.trippels.de>
	 <1321954729.2474.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321955185.2474.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1111220844400.25785@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

Le mardi 22 novembre 2011 A  08:46 -0600, Christoph Lameter a A(C)crit :
> On Tue, 22 Nov 2011, Eric Dumazet wrote:
> 
> > I trigger a bug in less than 10 secondes, with this running while a
> > "make -j16 " kernel build is run.
> >
> > while :; do slabinfo -v; done
> 
> Hmm.... Yeah there was limited testing on the debug features. There could
> be something amiss there. Need to review the validation interactions with
> the new code.
> 
> 

Hmm... yes, we probably should take a look.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
