Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7F36B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:31:43 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so259943038pad.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:31:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bl8si36048723pad.42.2016.07.25.17.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 17:26:11 -0700 (PDT)
Date: Mon, 25 Jul 2016 17:25:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 0/7] Make cpuid <-> nodeid mapping persistent
Message-Id: <20160725172549.e5a23d495a356f026fbb28fa@linux-foundation.org>
In-Reply-To: <20160726001151.GN19588@mtj.duckdns.org>
References: <1469435749-19582-1-git-send-email-douly.fnst@cn.fujitsu.com>
	<20160725162022.e90e9c6c74a5d147e39e5945@linux-foundation.org>
	<20160726001151.GN19588@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 25 Jul 2016 20:11:51 -0400 Tejun Heo <tj@kernel.org> wrote:

> Hello, Andrew.
> 
> On Mon, Jul 25, 2016 at 04:20:22PM -0700, Andrew Morton wrote:
> > > When a pool workqueue is initialized, if its cpumask belongs to a node, its
> > > pool->node will be mapped to that node. And memory used by this workqueue will
> > > also be allocated on that node.
> > 
> > Plan B is to hunt down and fix up all the workqueue structures at
> > hotplug-time.  Has that option been evaluated?
> > 
> > Your fix is x86-only and this bug presumably affects other
> > architectures, yes?  I think a "Plan B" would fix all architectures?
> 
> Yeah, that was one of the early approaches.  The issue isn't limited
> to wq.  Any memory allocation can have similar issues of underlying
> node association changing and we don't have any synchronization
> mechanism around it.  It doesn't make any sense to make NUMA
> association dynamic when the consumer surface is vastly larger and
> there's nothing inherently dynamic about the association itself.

And other architectures?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
