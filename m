Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A3E046B0081
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 08:21:47 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1364109934-7851-25-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-25-git-send-email-jiang.liu@huawei.com> <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
Subject: Re: [RFC PATCH v2, part4 16/39] mm/frv: prepare for removing num_physpages and simplify mem_init()
Date: Mon, 25 Mar 2013 12:21:28 +0000
Message-ID: <7011.1364214088@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>


Does your patch emailer have a bug in it?  Or did you submit a second batch 1s
after the first, but with different patch numbering?  Patches 16 & 17 and 24 &
25 and 25 & 26 look the same (I have two different copies of patch 25).

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
