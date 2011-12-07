Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 649446B004D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 09:39:17 -0500 (EST)
Date: Wed, 7 Dec 2011 15:39:13 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111207143913.GB1600@x4.trippels.de>
References: <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
 <20111123160353.GA1673@x4.trippels.de>
 <alpine.DEB.2.00.1111231004490.17317@router.home>
 <20111124085040.GA1677@x4.trippels.de>
 <20111201084437.GA1529@x4.trippels.de>
 <20111202194309.GA12057@homer.localdomain>
 <20111202200649.GA1603@x4.trippels.de>
 <20111202204820.GB1603@x4.trippels.de>
 <20111207143223.GX15738@erda.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111207143223.GX15738@erda.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@amd.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Christoph Lameter <cl@linux.com>, "Alex, Shi" <alex.shi@intel.com>, Dave Airlie <airlied@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, tj@kernel.org, Alex Deucher <alexander.deucher@amd.com>

On 2011.12.07 at 15:32 +0100, Robert Richter wrote:
> On 02.12.11 21:48:20, Markus Trippelsdorf wrote:
> > BTW I always see (mostly only on screen, sometimes in the logs):
> > 
> > [Firmware Bug]: cpu 2, try to use APIC500 (LVT offset 0) for vector 0x10400, but the register is already in use for vector 0xf9 on another cpu
> > [Firmware Bug]: cpu 2, IBS interrupt offset 0 not available (MSRC001103A=0x0000000000000100)
> > [Firmware Bug]: using offset 1 for IBS interrupts
> > [Firmware Bug]: workaround enabled for IBS LVT offset
> > perf: AMD IBS detected (0x0000001f) 
> > 
> > But I hope that it is only a harmless warning. 
> > (perf Instruction-Based Sampling)
> 
> Yes, the message always apears on AMD family 10h. Nothing to worry
> about.
> 
> A patch is on the way to soften the message to not scare the people:
> 
>  http://git.kernel.org/?p=linux/kernel/git/tip/tip.git;a=commit;h=16e5294e5f8303756a179cf218e37dfb9ed34417

Thanks.
It's already in mainline and the message is gone now.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=16e5294e5f8303756a179cf218e37dfb9ed34417

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
