Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3RJY4Ju007806
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 01:04:04 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3RJXwC11216662
	for <linux-mm@kvack.org>; Mon, 28 Apr 2008 01:03:58 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3RJYCUj028148
	for <linux-mm@kvack.org>; Sun, 27 Apr 2008 19:34:12 GMT
Message-ID: <4814D459.1020602@linux.vnet.ibm.com>
Date: Mon, 28 Apr 2008 01:00:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] Fix usemap initialization v3
References: <20080418161522.GB9147@csn.ul.ie> <48080706.50305@cn.fujitsu.com> <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com> <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com> <21878461.1208539556838.kamezawa.hiroyu@jp.fujitsu.com> <20080421112048.78f0ec76.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0804211250000.16476@blonde.site> <20080422104043.215c7dc4.kamezawa.hiroyu@jp.fujitsu.com> <20080423134621.6020dd83.kamezawa.hiroyu@jp.fujitsu.com> <20080427121817.03b432ca.akpm@linux-foundation.org>
In-Reply-To: <20080427121817.03b432ca.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Mel Gorman <mel@csn.ul.ie>, Shi Weihua <shiwh@cn.fujitsu.com>, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> Do we think this is needed in 2.6.25.x?

My answer would be yes. Shi reproduced this problem with 2.6.25

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
