Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8U8ELr9026511
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 13:44:21 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8U8ELje1708090
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 13:44:21 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8U8EK9L009853
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 18:14:20 +1000
Message-ID: <48E1DFDC.4000706@linux.vnet.ibm.com>
Date: Tue, 30 Sep 2008 13:44:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] memcg: avoid account not-on-LRU pages
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com> <20080929192339.327ca142.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080929192339.327ca142.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> +		if (charged)
> +			mem_cgroup_uncharge_page(page);
> +		if (anon) {
>  			page_cache_release(page);
> -		else
> +		} else
>  			anon = 1; /* no anon but release faulted_page */
>  	}

Coding style braces for a single-line if-else, please recheck

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
