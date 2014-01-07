Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 95D0C6B0036
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:39:27 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id uy17so462755igb.4
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:39:27 -0800 (PST)
Received: from g4t0017.houston.hp.com (g4t0017.houston.hp.com. [15.201.24.20])
        by mx.google.com with ESMTPS id ix6si97489446icb.96.2014.01.06.18.39.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 18:39:26 -0800 (PST)
Message-ID: <1389062352.9937.2.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v3 02/14] mm, hugetlb: region manipulation functions
 take resv_map rather list_head
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 06 Jan 2014 18:39:12 -0800
In-Reply-To: <1387349640-8071-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1387349640-8071-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Wed, 2013-12-18 at 15:53 +0900, Joonsoo Kim wrote:
> To change a protection method for region tracking to find grained one,
> we pass the resv_map, instead of list_head, to region manipulation
> functions. This doesn't introduce any functional change, and it is just
> for preparing a next step.
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
