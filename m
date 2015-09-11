Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 698556B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 20:14:43 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so33264319igc.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 17:14:43 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id y66si12369542ioi.149.2015.09.10.17.14.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Sep 2015 17:14:42 -0700 (PDT)
Date: Thu, 10 Sep 2015 19:14:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/7] x86, gfp: Cache best near node for memory
 allocation.
In-Reply-To: <20150910193819.GJ8114@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.11.1509101908410.11150@east.gentwo.org>
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

Yes that should occur in the absence of other constraints (mempolicies,
cpusets, cgroups, allocation type). If the constraints do not allow an
allocation then the allocation will fail.

Also: Are the zonelists setup the right way?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
