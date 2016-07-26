Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76D716B0263
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 21:03:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id q11so413430540qtb.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 18:03:47 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id z197si19479125qkz.259.2016.07.25.18.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 18:03:46 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id p126so15599259qke.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 18:03:46 -0700 (PDT)
Date: Mon, 25 Jul 2016 21:03:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 0/7] Make cpuid <-> nodeid mapping persistent
Message-ID: <20160726010344.GO19588@mtj.duckdns.org>
References: <1469435749-19582-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <20160725162022.e90e9c6c74a5d147e39e5945@linux-foundation.org>
 <20160726001151.GN19588@mtj.duckdns.org>
 <20160725172549.e5a23d495a356f026fbb28fa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160725172549.e5a23d495a356f026fbb28fa@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dou Liyang <douly.fnst@cn.fujitsu.com>, cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Mon, Jul 25, 2016 at 05:25:49PM -0700, Andrew Morton wrote:
> > Yeah, that was one of the early approaches.  The issue isn't limited
> > to wq.  Any memory allocation can have similar issues of underlying
> > node association changing and we don't have any synchronization
> > mechanism around it.  It doesn't make any sense to make NUMA
> > association dynamic when the consumer surface is vastly larger and
> > there's nothing inherently dynamic about the association itself.
> 
> And other architectures?

No idea but it only matters for NUMA + CPU hotplug combination where a
whole node can go empty, which would at most be a few archs.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
