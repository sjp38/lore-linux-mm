Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA9LUrsa025357
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 16:30:53 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA9LUrgj122406
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 14:30:53 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA9LUqA5020202
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 14:30:53 -0700
Subject: Re: about page migration on UMA
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0711091156170.15914@schroedinger.engr.sgi.com>
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
Content-Type: text/plain
Date: Fri, 09 Nov 2007 13:30:50 -0800
Message-Id: <1194643851.7078.112.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jared Hulbert <jaredeh@gmail.com>, "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-09 at 11:58 -0800, Christoph Lameter wrote:
> Well one idea is to generate a sysfs file that can take a physical memory 
> range? echo the range to the sysfs file. The kernel can then try to 
> vacate the memory range.

When memory hotplug is on, you should see memory broken up into
"sections", and exported in sysfs today:

	/sys/devices/system/memory

You can on/offline memory from there, and it should be pretty easy to
figure out the physical addresses with the phys_index file.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
