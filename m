Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C25986B0264
	for <linux-mm@kvack.org>; Wed, 25 May 2016 16:37:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d7so146726345qkf.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 13:37:34 -0700 (PDT)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id y67si443321ywe.20.2016.05.25.13.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 13:37:33 -0700 (PDT)
Received: by mail-yw0-x243.google.com with SMTP id y6so8566396ywe.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 13:37:33 -0700 (PDT)
Date: Wed, 25 May 2016 16:37:31 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v7 0/5] Make cpuid <-> nodeid mapping persistent
Message-ID: <20160525203731.GJ3354@mtj.duckdns.org>
References: <cover.1463652944.git.zhugh.fnst@cn.fujitsu.com>
 <20160519144657.GK3206@twins.programming.kicks-ass.net>
 <5742AAF6.3060901@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5742AAF6.3060901@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, cl@linux.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 23, 2016 at 03:02:14PM +0800, Zhu Guihua wrote:
> We tried to do that. You can see our patch at
> http://www.gossamer-threads.com/lists/linux/kernel/2116748
> 
> But maintainer thought, we should establish persistent cpuid<->nodeid
> relationship,
> there is no need to change the map.
> 
> Cc TJ,
> Could we return to workqueue to fix this?

Workqueue is just one of symptoms.  We have the same problem for
memory allocation paths.  It's either keeping cpu <-> node mapping
persistent or hunting down every case which may be affected and build
likely costly synchronization construct around it.  It's not like we
have a lot of archs which support CPU hotplug and NUMA.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
