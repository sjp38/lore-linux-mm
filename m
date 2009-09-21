Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A387A6B004F
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 12:21:35 -0400 (EDT)
Date: Mon, 21 Sep 2009 09:21:30 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Message-ID: <20090921092130.30984dbd@s6510>
In-Reply-To: <200909211637.23299.rusty@rustcorp.com.au>
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com>
	<20090901090518.1193e412@nehalam>
	<200909211637.23299.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org, "Xin, Xiaohui" <xiaohui.xin@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Sep 2009 16:37:22 +0930
Rusty Russell <rusty@rustcorp.com.au> wrote:

> > > Actually this framework can apply to traditional network adapters which have
> > > just one tx/rx queue pair. And applications using the same user/kernel interface
> > > can utilize this framework to send/receive network traffic directly thru a tx/rx
> > > queue pair in a network adapter.
> > > 

More importantly, when virtualizations is used with multi-queue NIC's the virtio-net
NIC is a single CPU bottleneck. The virtio-net NIC should preserve the parallelism (lock
free) using multiple receive/transmit queues. The number of queues should equal the
number of CPUs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
