Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l92N7mgk031607
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 19:07:48 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92N7mdU456514
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 17:07:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92N7ljm017437
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 17:07:47 -0600
Subject: Re: [RFC] PPC64 Exporting memory information through /proc/iomem
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
	 <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
Content-Type: text/plain
Date: Tue, 02 Oct 2007 16:10:53 -0700
Message-Id: <1191366653.6106.68.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@ozlabs.org, linux-mm <linux-mm@kvack.org>, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-03 at 08:56 +1000, Paul Mackerras wrote:
> Badari Pulavarty writes:
> 
> > I am trying to get hotplug memory remove working on ppc64.
> > In order to verify a given memory region, if its valid or not -
> > current hotplug-memory patches used /proc/iomem. On IA64 and
> > x86-64 /proc/iomem shows all memory regions. 
> > 
> > I am wondering, if its acceptable to do the same on ppc64 also ?
> 
> I am a bit hesitant to do that, since /proc/iomem is user visible and
> is therefore part of the user/kernel ABI.  Also it feels a bit weird
> to have system RAM in something whose name suggests it's about MMIO.

Yes. That was my first reaction. Until last week, I never realized
that /proc/iomem contains entire memory layout on i386/x86-64 :(

Since i386, x86-64 and ia64 are all doing same thing, I thought breakage
would be minimal (if any) if we do the same on ppc64.

> > Otherwise, we need to add arch-specific hooks in hotplug-remove
> > code to be able to do this.
> 
> Isn't it just a matter of abstracting the test for a valid range of
> memory?  If it's really hard to abstract that, then I guess we can put
> RAM in iomem_resource, but I'd rather not.
> 

Sure. I will work on it and see how ugly it looks.

KAME, are you okay with abstracting the find_next_system_ram() and
let arch provide whatever implementation they want ? (since current
code doesn't work for x86-64 also ?).

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
