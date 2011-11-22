Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 687836B0070
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 03:37:10 -0500 (EST)
Date: Tue, 22 Nov 2011 00:37:03 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <1321928235.13860.31.camel@pasglop>
Message-ID: <alpine.DEB.2.01.1111220030570.8000@trent.utfs.org>
References: <20111121131531.GA1679@x4.trippels.de>  <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121153621.GA1678@x4.trippels.de>  <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121161036.GA1679@x4.trippels.de>
  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121173556.GA1673@x4.trippels.de>  <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121185215.GA1673@x4.trippels.de>
  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>  <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org> <1321928235.13860.31.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, 22 Nov 2011 at 13:17, Benjamin Herrenschmidt wrote:
> Is your powerbook one of those who can actually use xmon ? (ie, keyboard
> is working ? If it's usb it won't but if it's adb it will).

Yes, with CONFIG_XMON=y the xmon> prompt appeared on the screen and the 
keyboard was working too. See the xmon* jpegs here:

   http://nerdbynature.de/bits/3.2.0-rc1/oops/

> What would be useful would be to see if you can reproduce with SLAB
> and/or after backing out the cpu partial functionality.

I'm currently running with SLUB again but with 
/sys/kernel/slab/*/cpu_partial all set to "0" (affecting ~250 files).

The box is running for some hours now and pretty loaded with both CPU and 
disk i/o (load 6-7, which is pretty high for this machine) and it did not 
oops yet. Looks like setting cpu_partial to 0 does make a difference.

Christian.

# cat /proc/cpuinfo 
processor       : 0
cpu             : 7447A, altivec supported
clock           : 749.999000MHz
revision        : 1.2 (pvr 8003 0102)
bogomips        : 36.86
timebase        : 18432000
platform        : PowerMac
model           : PowerBook6,8
machine         : PowerBook6,8
motherboard     : PowerBook6,8 MacRISC3 Power Macintosh 
detected as     : 287 (PowerBook G4 12")
pmac flags      : 0000001a
L2 cache        : 512K unified
pmac-generation : NewWorld
Memory          : 1280 MB

-- 
BOFH excuse #176:

vapors from evaporating sticky-note adhesives

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
