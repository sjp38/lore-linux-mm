Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2886B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 19:35:34 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so138984985pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:35:34 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id tn4si35348673pbc.45.2015.08.25.16.35.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 16:35:33 -0700 (PDT)
Received: by pacti10 with SMTP id ti10so66113357pac.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:35:33 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:35:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memory-hotplug: fix comment in zone_spanned_pages_in_node()
 and zone_spanned_pages_in_node()
In-Reply-To: <55DBCCE2.3070901@huawei.com>
Message-ID: <alpine.DEB.2.10.1508251635210.10653@chino.kir.corp.google.com>
References: <55DBCCE2.3070901@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, 25 Aug 2015, Xishi Qiu wrote:

> When hotadd a node from add_memory(), we will add memblock first, so the
> node is not empty. But when from cpu_up(), the node should be empty.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
