Date: Mon, 12 Nov 2007 09:50:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: about page migration on UMA
Message-Id: <20071112095000.48aaed78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1194643851.7078.112.camel@localhost>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
	<20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
	<20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
	<02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
	<Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com>
	<6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
	<Pine.LNX.4.64.0711091136270.15605@schroedinger.engr.sgi.com>
	<6934efce0711091154x74fe4405q5a9e291b3d9780f0@mail.gmail.com>
	<Pine.LNX.4.64.0711091156170.15914@schroedinger.engr.sgi.com>
	<1194643851.7078.112.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Jared Hulbert <jaredeh@gmail.com>, "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 09 Nov 2007 13:30:50 -0800
Dave Hansen <haveblue@us.ibm.com> wrote:

> On Fri, 2007-11-09 at 11:58 -0800, Christoph Lameter wrote:
> > Well one idea is to generate a sysfs file that can take a physical memory 
> > range? echo the range to the sysfs file. The kernel can then try to 
> > vacate the memory range.
> 
> When memory hotplug is on, you should see memory broken up into
> "sections", and exported in sysfs today:
> 
> 	/sys/devices/system/memory
> 
> You can on/offline memory from there, and it should be pretty easy to
> figure out the physical addresses with the phys_index file.
> 

yes.

Using current memory-hotplug interface is the easiest way.

What you have to do in your arch is...

 1. support SPARSEMEM and define SECTION_SIZE to be suitable
 2. add Memory Hotplug config. see mm/Kconfig
 3. use ZONE_MOVABLE with boot option.
 4. maybe you have to find that you have to define your own walk_memory_resource()
    or not.

Maybe reading  Badari's patches in these days for ppc64 support will help you.
Contiguous memory-size memory can be offlined.

One problem I don't understand is memory hotplug cannot be used if
CONFIG_HIBERNATION is on. If this is problem to you, you may need
some work.

Regards,
 -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
