Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2D84E6B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 13:26:20 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id eb12so9746627oac.2
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 10:26:19 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id kb5si12720191obb.95.2014.03.31.10.26.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 10:26:19 -0700 (PDT)
Message-ID: <1396286773.2507.11.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v3 00/14] mm, hugetlb: remove a
 hugetlb_instantiation_mutex
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 31 Mar 2014 10:26:13 -0700
In-Reply-To: <5339977F.4070905@intel.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <5339977F.4070905@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Mon, 2014-03-31 at 09:27 -0700, Dave Hansen wrote:
> On 12/17/2013 10:53 PM, Joonsoo Kim wrote:
> > * NOTE for v3
> > - Updating patchset is so late because of other works, not issue from
> > this patchset.
> 
> Hey Joonsoo,
> 
> Any plans to repost these?
> 
> I've got some folks with a couple TB of RAM seeing long startup times
> with $LARGE_DATABASE_PRODUCT.  It looks to be contention on
> hugetlb_instantiation_mutex because everyone is trying to zero hugepages
> under that lock in parallel.  Just removing the lock sped things up
> quite a bit.

Welcome to my world. Regarding the instantiation mutex, it is addressed,
see commit c999c05ff595 in -next. 

As for the clear page overhead, I brought this up in lsfmm last week,
proposing some daemon to clear pages when we have idle cpu... but didn't
get much positive feedback. Basically (i) not worth the additional
complexity and (ii) can trigger different application startup times,
which seems to be something negative. I do have a patch that implements
huge_clear_page with non-temporal hinting but I didn't see much
difference on my environment, would you want to give it a try?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
