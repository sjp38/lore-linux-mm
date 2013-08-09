Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 9E4D06B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:37:26 -0400 (EDT)
Date: Fri, 9 Aug 2013 18:37:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 17/18] mm, hugetlb: retry if we fail to allocate a
 hugepage with use_reserve
Message-ID: <20130809093724.GA11091@lge.com>
References: <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
 <20130729072823.GD29970@voom.fritz.box>
 <20130731053753.GM2548@lge.com>
 <20130803104302.GC19115@voom.redhat.com>
 <20130805073647.GD27240@lge.com>
 <1375834724.2134.49.camel@buesod1.americas.hpqcorp.net>
 <20130807010312.GA17110@voom.redhat.com>
 <1375839529.2134.50.camel@buesod1.americas.hpqcorp.net>
 <20130807091832.GD32449@lge.com>
 <20130809000231.GB2904@voom.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130809000231.GB2904@voom.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

> I once attempted an approach involving an atomic counter of the number
> of "in flight" hugepages, only retrying when it's non zero.  Working
> out a safe ordering for all the updates to get all the cases right
> made my brain melt though, and I never got it working.

I sent v2 few seconds before. My new approach is similar as yours.
Could you review my patches to save my brain to be melted? :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
