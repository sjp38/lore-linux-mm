Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id E51536B0035
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 09:13:05 -0400 (EDT)
Received: by mail-yh0-f46.google.com with SMTP id a41so4398791yho.5
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 06:13:05 -0700 (PDT)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id v64si20155447yhm.193.2014.08.18.06.13.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 18 Aug 2014 06:13:05 -0700 (PDT)
Received: by mail-yh0-f51.google.com with SMTP id f73so4443231yha.10
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 06:13:05 -0700 (PDT)
Date: Mon, 18 Aug 2014 09:13:01 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
Message-ID: <20140818131301.GA16425@mtj.dyndns.org>
References: <53E8C5AA.5040506@huawei.com>
 <20140816130456.GH9305@htj.dyndns.org>
 <53EF6C79.3000603@huawei.com>
 <20140817110821.GM9305@htj.dyndns.org>
 <53F15330.5070606@cn.fujitsu.com>
 <53F17068.5000005@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53F17068.5000005@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: tangchen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello, Xishi, Tang.

On Mon, Aug 18, 2014 at 11:18:00AM +0800, Xishi Qiu wrote:
> If all the nodes are marked hotpluggable flag, alloc node data will fail.
> Because __next_mem_range_rev() will skip the hotpluggable memory regions.
> numa_register_memblks()
> 	setup_node_data()
> 		memblock_find_in_range_node()
> 			__memblock_find_range_top_down()
> 				for_each_mem_range_rev()
> 					__next_mem_range_rev()

I'm not sure clearing hotplug flag for all memory is the best approach
here.  The problem is that there are places where we want to be
selectively ignoring the hotplug status and apparently we may want it
back later.  Why not add an agument to memblock allocation / iteration
functions so that hotplug area can be skipped selectively?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
