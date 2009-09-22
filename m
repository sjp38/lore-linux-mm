Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A1CF36B006A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 14:34:56 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Date: Tue, 22 Sep 2009 20:34:28 +0200
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com> <200909221350.54847.arnd@arndb.de> <20090922092957.17e68cbc@s6510>
In-Reply-To: <20090922092957.17e68cbc@s6510>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909222034.28865.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Stephen Hemminger <shemminger@vyatta.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, "Xin, Xiaohui" <xiaohui.xin@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 22 September 2009, Stephen Hemminger wrote:
> > My idea for that was to open multiple file descriptors to the same
> > macvtap device and let the kernel figure out the  right thing to
> > do with that. You can do the same with raw packed sockets in case
> > of vhost_net, but I wouldn't want to add more complexity to the
> > tun/tap driver for this.
> > 
> Or get tap out of the way entirely. The packets should not have
> to go out to user space at all (see veth)

How does veth relate to that, do you mean vhost_net? With vhost_net,
you could still open multiple sockets, only the access is in the kernel.
Obviously, once it all is in the kernel, that could be done under the
covers, but I think it would be cleaner to treat vhost_net purely as
a way to bypass the syscalls for user space, with as little as possible
visible impact otherwise.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
