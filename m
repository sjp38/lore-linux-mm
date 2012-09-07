Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 39CA76B002B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 18:59:03 -0400 (EDT)
Received: by dadi14 with SMTP id i14so64135dad.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 15:59:02 -0700 (PDT)
Date: Fri, 7 Sep 2012 15:58:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH RESEND]mm/ia64: fix a node distance bug
In-Reply-To: <50484E2C.1060107@gmail.com>
Message-ID: <alpine.DEB.2.00.1209071558430.28027@chino.kir.corp.google.com>
References: <50484E2C.1060107@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wujianguo <wujianguo106@gmail.com>
Cc: tony.luck@intel.com, akpm@linux-foundation.org, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jiang.liu@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com

On Thu, 6 Sep 2012, wujianguo wrote:

> From: Jianguo Wu <wujianguo@huawei.com>
> 
> In arch ia64, has following definition:
> extern u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
> #define node_distance(from,to) (numa_slit[(from) * num_online_nodes() + (to)])
> 
> num_online_nodes() is a variable value, it can be changed after hot-remove/add
> a node.
> 
> I my practice, I found node distance is wrong after offline
> a node in IA64 platform. For example system has 4 nodes:
> node distances:
> node   0   1   2   3
>   0:  10  21  21  32
>   1:  21  10  32  21
>   2:  21  32  10  21
>   3:  32  21  21  10
> 
> linux-drf:/sys/devices/system/node/node0 # cat distance
> 10  21  21  32
> linux-drf:/sys/devices/system/node/node1 # cat distance
> 21  10  32  21
> 
> After offline node2:
> linux-drf:/sys/devices/system/node/node0 # cat distance
> 10 21 32
> linux-drf:/sys/devices/system/node/node1 # cat distance
> 32 21 32	--------->expected value is: 21  10  21
> 
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
