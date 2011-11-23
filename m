Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 84CA06B00BD
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 20:22:19 -0500 (EST)
Date: Tue, 22 Nov 2011 17:22:14 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <1322007501.14573.15.camel@pasglop>
Message-ID: <alpine.DEB.2.01.1111221711410.8000@trent.utfs.org>
References: <20111121131531.GA1679@x4.trippels.de>  <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121153621.GA1678@x4.trippels.de>  <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121161036.GA1679@x4.trippels.de>
  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121173556.GA1673@x4.trippels.de>  <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121185215.GA1673@x4.trippels.de>
  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>  <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>  <alpine.DEB.2.00.1111212105330.19606@router.home>  <1321948113.27077.24.camel@edumazet-laptop>  <1321999085.14573.2.camel@pasglop>
  <alpine.DEB.2.01.1111221511070.8000@trent.utfs.org> <1322007501.14573.15.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Christoph Lameter <cl@linux.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Wed, 23 Nov 2011 at 11:18, Benjamin Herrenschmidt wrote:
> I'd say only this one liner for now, just don't do slabinfo :-)

It's still building, for 2hrs now, must be those debug options I added, a 
"normal" build on this machine "only" takes 30min otherwise. Unfortunately 
I failed to setup a crosscompile env with the latest crosstool checkout :(

> I just want to see whether your network + heavy IO load problem goes
> away with that one patch.

Sorry, I should have been clearer in that mail: the high "load" value 
isn't a problem - the intermittent panics are. What I meant to say was: 
the panics usually occur when lots of disk & cpu IO is in progress (rsync 
to an external but local disk over firewire). While doing this the load is 
usally at 3-5, but that's "normal" and expected for a machine of that age. 

But then the machine crashes with recent kernels. After setting the 
cpu_partial files to 0 I tried to reproduce the same I/O pattern, *plus* a 
bit more, to really stress the machine, so load went up to 6-7 and the 
machine did not crash. So the load of 6-7 was expected and I'm glad that 
the machine did not crash with that workaround. I don't know of the 
implications of setting cpu_partial to 0 though.

As soon as the build with Christoph's one-liner is done I'll test w/o 
setting cpu_partial to 0 and see what it gives.

Thanks,
Christian.
-- 
BOFH excuse #380:

Operators killed when huge stack of backup tapes fell over.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
