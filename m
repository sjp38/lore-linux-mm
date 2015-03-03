Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5746B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 22:30:52 -0500 (EST)
Received: by pdno5 with SMTP id o5so44806256pdn.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 19:30:51 -0800 (PST)
Received: from szxga01-in.huawei.com ([119.145.14.64])
        by mx.google.com with ESMTPS id sa3si7640323pac.27.2015.03.02.19.30.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 19:30:51 -0800 (PST)
Message-ID: <54F52ACF.4030103@huawei.com>
Date: Tue, 3 Mar 2015 11:30:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: node-hotplug: is memset 0 safe in try_offline_node()?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>

When hot-remove a numa node, we will clear pgdat,
but is memset 0 safe in try_offline_node()?

process A:			offline node XX:
for_each_populated_zone()
find online node XX
cond_resched()
				offline cpu and memory, then try_offline_node()
				node_set_offline(nid), and memset(pgdat, 0, sizeof(*pgdat))
access node XX's pgdat
NULL pointer access error

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
