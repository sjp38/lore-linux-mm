Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 43B776B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 10:25:19 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so8773698qgf.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 07:25:19 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id c41si8236777qge.65.2015.04.23.07.25.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 07:25:18 -0700 (PDT)
Date: Thu, 23 Apr 2015 09:25:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <1429756200.4915.19.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.11.1504230921020.32297@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <1429756200.4915.19.camel@kernel.crashing.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:

> They are via MMIO space. The big differences here are that via CAPI the
> memory can be fully cachable and thus have the same characteristics as
> normal memory from the processor point of view, and the device shares
> the MMU with the host.
>
> Practically what that means is that the device memory *is* just some
> normal system memory with a larger distance. The NUMA model is an
> excellent representation of it.

I sure wish you would be working on using these features to increase
performance and the speed of communication to devices.

Device memory is inherently different from main memory (otherwise the
device would be using main memory) and thus not really NUMA. NUMA at least
assumes that the basic characteristics of memory are the same while just
the access speeds vary. GPU memory has very different performance
characteristics and the various assumptions on memory that the kernel
makes for the regular processors may not hold anymore.

> For my use cases the advantage of CAPI lies in the reduction of latency
> > for coprocessor communication. I hope that CAPI will allow fast cache to
> > cache transactions between a coprocessor and the main one. This is
> > improving the ability to exchange data rapidly between a application code
> > and some piece of hardware (NIC, GPU, custom hardware etc etc)
> >
> > Fundamentally this is currently an design issue since CAPI is running on
> > top of PCI-E and PCI-E transactions establish a minimum latency that
> > cannot be avoided. So its hard to see how CAPI can improve the situation.
>
> It's on top of the lower layers of PCIe yes, I don't know the exact
> latency numbers. It does enable the device to own cache lines though and
> vice versa.

Could you come up with a way to allow faster device communication through
improving on the PCI-E cacheline handoff via CAPI? That would be something
useful that I expected from it. If the processor can transfer some word
faster into a CAPI device or get status faster then that is a valuable
thing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
