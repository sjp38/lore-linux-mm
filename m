Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7361E6B00BE
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 12:30:10 -0400 (EDT)
Date: Tue, 22 Sep 2009 09:29:57 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Message-ID: <20090922092957.17e68cbc@s6510>
In-Reply-To: <200909221350.54847.arnd@arndb.de>
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com>
	<20090921162718.GM26034@sequoia.sous-sol.org>
	<20090922103807.GA2555@redhat.com>
	<200909221350.54847.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, "Xin, Xiaohui" <xiaohui.xin@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Sep 2009 13:50:54 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Tuesday 22 September 2009, Michael S. Tsirkin wrote:
> > > > More importantly, when virtualizations is used with multi-queue
> > > > NIC's the virtio-net NIC is a single CPU bottleneck. The virtio-net
> > > > NIC should preserve the parallelism (lock free) using multiple
> > > > receive/transmit queues. The number of queues should equal the
> > > > number of CPUs.
> > > 
> > > Yup, multiqueue virtio is on todo list ;-)
> > > 
> > 
> > Note we'll need multiqueue tap for that to help.
> 
> My idea for that was to open multiple file descriptors to the same
> macvtap device and let the kernel figure out the  right thing to
> do with that. You can do the same with raw packed sockets in case
> of vhost_net, but I wouldn't want to add more complexity to the
> tun/tap driver for this.
> 
> 	Arnd <><


Or get tap out of the way entirely. The packets should not have
to go out to user space at all (see veth)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
