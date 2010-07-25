Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5AF056B02A4
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 04:28:38 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2157840iwn.14
        for <linux-mm@kvack.org>; Sun, 25 Jul 2010 01:28:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100723141111.88A8.A69D9226@jp.fujitsu.com>
References: <20100716191334.736F.A69D9226@jp.fujitsu.com>
	<20100722044911.GK14369@balbir.in.ibm.com>
	<20100723141111.88A8.A69D9226@jp.fujitsu.com>
Date: Sun, 25 Jul 2010 13:58:42 +0530
Message-ID: <AANLkTi=wFkujwaMYrREJ1=sop_CZAsX2Nc7kcC3nji-t@mail.gmail.com>
Subject: Re: [PATCH 2/7] memcg: mem_cgroup_shrink_node_zone() doesn't need
	sc.nodemask
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

>>
>> We need the initialization to 0, is there a reason why it was removed?
>
> please reread C spec and other scan_control user.
> sc_nr_* were already initialized in struct scan_control sc = { } line.
>

I missed the fact that  designated initializers do the right thing. Thanks!

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
