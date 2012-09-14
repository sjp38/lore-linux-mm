Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 6246A6B005A
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 12:24:34 -0400 (EDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH RESEND] memory hotplug: fix a double register section
 info bug
Date: Fri, 14 Sep 2012 16:24:32 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F19D40E81@ORSMSX108.amr.corp.intel.com>
References: <5052A7DF.4050301@gmail.com> <20120914095230.GE11266@suse.de>
In-Reply-To: <20120914095230.GE11266@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, qiuxishi <qiuxishi@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "bessel.wang@huawei.com" <bessel.wang@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rientjes@google.com" <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wen Congyang <wency@cn.fujitsu.com>

> This is an unusual configuration but it's not unheard of. PPC64 in rare
> (and usually broken) configurations can have one node span another. Tony
> should know if such a configuration is normally allowed on Itanium or if
> this should be considered a platform bug. Tony?

We definitely have platforms where the physical memory on node 0
that we skipped to leave physical address space for PCI mem mapped
devices gets tagged back at the very top of memory, after other nodes.

E.g. A 2-node system with 8G on each might look like this:

0-2G RAM on node 0
2G-4G  PCI map space
4G-8G RAM on node 0
8G-16GRAM on node 1
16G-18G RAM on node 0

Is this the situation that we are talking about? Or something different?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
