Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 996A86B0037
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 12:29:21 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so8404434pbc.23
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 09:29:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bp1si9488421pbb.49.2014.03.31.09.29.20
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 09:29:20 -0700 (PDT)
Message-ID: <5339977F.4070905@intel.com>
Date: Mon, 31 Mar 2014 09:27:43 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/14] mm, hugetlb: remove a hugetlb_instantiation_mutex
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On 12/17/2013 10:53 PM, Joonsoo Kim wrote:
> * NOTE for v3
> - Updating patchset is so late because of other works, not issue from
> this patchset.

Hey Joonsoo,

Any plans to repost these?

I've got some folks with a couple TB of RAM seeing long startup times
with $LARGE_DATABASE_PRODUCT.  It looks to be contention on
hugetlb_instantiation_mutex because everyone is trying to zero hugepages
under that lock in parallel.  Just removing the lock sped things up
quite a bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
