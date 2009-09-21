Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 00C686B0062
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 12:27:28 -0400 (EDT)
Date: Mon, 21 Sep 2009 09:27:18 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Message-ID: <20090921162718.GM26034@sequoia.sous-sol.org>
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com> <20090901090518.1193e412@nehalam> <200909211637.23299.rusty@rustcorp.com.au> <20090921092130.30984dbd@s6510>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090921092130.30984dbd@s6510>
Sender: owner-linux-mm@kvack.org
To: Stephen Hemminger <shemminger@vyatta.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, "Xin, Xiaohui" <xiaohui.xin@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Stephen Hemminger (shemminger@vyatta.com) wrote:
> On Mon, 21 Sep 2009 16:37:22 +0930
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> 
> > > > Actually this framework can apply to traditional network adapters which have
> > > > just one tx/rx queue pair. And applications using the same user/kernel interface
> > > > can utilize this framework to send/receive network traffic directly thru a tx/rx
> > > > queue pair in a network adapter.
> > > > 
> 
> More importantly, when virtualizations is used with multi-queue NIC's the virtio-net
> NIC is a single CPU bottleneck. The virtio-net NIC should preserve the parallelism (lock
> free) using multiple receive/transmit queues. The number of queues should equal the
> number of CPUs.

Yup, multiqueue virtio is on todo list ;-)

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
