Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7314A600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 14:04:28 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o72Hlahj018483
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 13:47:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o72I4WZc114138
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 14:04:32 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o72I4VkO001279
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 15:04:32 -0300
Date: Mon, 2 Aug 2010 23:34:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/7][memcg] cgroup arbitarary ID allocation
Message-ID: <20100802180429.GY3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
 <20100727165417.dacbe199.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100727165417.dacbe199.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-07-27 16:54:17]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> When a subsystem want to make use of "id" more, it's necessary to
> manage the id at cgroup subsystem creation time. But, now,
> because of the order of cgroup creation callback, subsystem can't
> declare the id it wants. This patch allows subsystem to use customized
> ID for themselves.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---

What happens if the id is taken already? Could you please explain how
this is used?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
