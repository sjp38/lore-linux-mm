Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 939C76B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:13:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q11so410711935qtb.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:13:10 -0700 (PDT)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id t31si19433847qta.62.2016.07.25.17.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 17:11:55 -0700 (PDT)
Received: by mail-qt0-x241.google.com with SMTP id q11so9286400qtb.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:11:54 -0700 (PDT)
Date: Mon, 25 Jul 2016 20:11:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 0/7] Make cpuid <-> nodeid mapping persistent
Message-ID: <20160726001151.GN19588@mtj.duckdns.org>
References: <1469435749-19582-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <20160725162022.e90e9c6c74a5d147e39e5945@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160725162022.e90e9c6c74a5d147e39e5945@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Andrew.

On Mon, Jul 25, 2016 at 04:20:22PM -0700, Andrew Morton wrote:
> > When a pool workqueue is initialized, if its cpumask belongs to a node, its
> > pool->node will be mapped to that node. And memory used by this workqueue will
> > also be allocated on that node.
> 
> Plan B is to hunt down and fix up all the workqueue structures at
> hotplug-time.  Has that option been evaluated?
> 
> Your fix is x86-only and this bug presumably affects other
> architectures, yes?  I think a "Plan B" would fix all architectures?

Yeah, that was one of the early approaches.  The issue isn't limited
to wq.  Any memory allocation can have similar issues of underlying
node association changing and we don't have any synchronization
mechanism around it.  It doesn't make any sense to make NUMA
association dynamic when the consumer surface is vastly larger and
there's nothing inherently dynamic about the association itself.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
