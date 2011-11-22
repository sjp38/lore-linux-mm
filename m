Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 982D46B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 19:22:10 -0500 (EST)
Date: Mon, 21 Nov 2011 16:21:49 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <1321907275.13860.12.camel@pasglop>
Message-ID: <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
References: <20111121131531.GA1679@x4.trippels.de>  <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121153621.GA1678@x4.trippels.de>  <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121161036.GA1679@x4.trippels.de>
  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121173556.GA1673@x4.trippels.de>  <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121185215.GA1673@x4.trippels.de>
  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, 22 Nov 2011 at 07:27, Benjamin Herrenschmidt wrote:
> Note that I hit a similar looking crash (sorry, I couldn't capture a
> backtrace back then) on a PowerMac G5 (ppc64) while doing a large rsync
> transfer yesterday with -rc2-something (cfcfc9ec) and 
> Christian Kujau (CC) seems to be able to reproduce something similar on
> some other ppc platform (Christian, what is your setup ?)

I seem to hit it with heavy disk & cpu IO is in progress on this PowerBook 
G4. Full dmesg & .config: http://nerdbynature.de/bits/3.2.0-rc1/oops/

I've enabled some debug options and now it really points to slub.c:2166

   http://nerdbynature.de/bits/3.2.0-rc1/oops/oops4m.jpg

With debug options enabled I'm currently in the xmon debugger, not sure 
what to make of it yet, I'll try to get something useful out of it :)

Christian.
-- 
BOFH excuse #399:

We are a 100% Microsoft Shop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
