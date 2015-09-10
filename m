Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id B5D1D6B0256
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 18:02:33 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so77551467ioi.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 15:02:33 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id eh3si6540078igb.11.2015.09.10.15.02.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 15:02:33 -0700 (PDT)
Date: Thu, 10 Sep 2015 17:02:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/7] x86, gfp: Cache best near node for memory
 allocation.
In-Reply-To: <20150910193819.GJ8114@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.11.1509101701220.11096@east.gentwo.org>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com> <1441859269-25831-4-git-send-email-tangchen@cn.fujitsu.com> <20150910192935.GI8114@mtj.duckdns.org> <20150910193819.GJ8114@mtj.duckdns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

On Thu, 10 Sep 2015, Tejun Heo wrote:

> > Why not just update node_data[]->node_zonelist in the first place?
> > Also, what's the synchronization rule here?  How are allocators
> > synchronized against node hot [un]plugs?
>
> Also, shouldn't kmalloc_node() or any public allocator fall back
> automatically to a near node w/o GFP_THISNODE?  Why is this failing at
> all?  I get that cpu id -> node id mapping changing messes up the
> locality but allocations shouldn't fail, right?

Without a node specification allocations are subject to various
constraints and memory policies. It is not simply going to the next node.
The memory load may require spreading out the allocations over multiple
nodes, the app may have specified which nodes are to be used etc etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
