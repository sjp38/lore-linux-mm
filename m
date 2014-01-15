Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id B2DA46B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 22:08:24 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id e9so506455qcy.12
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:08:24 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id f3si1275853qar.68.2014.01.14.19.08.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 19:08:23 -0800 (PST)
Received: by mail-yk0-f175.google.com with SMTP id q200so218416ykb.6
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:08:23 -0800 (PST)
Date: Tue, 14 Jan 2014 19:08:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
In-Reply-To: <1389062214.9937.0.camel@buesod1.americas.hpqcorp.net>
Message-ID: <alpine.DEB.2.02.1401141906350.451@chino.kir.corp.google.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com> <1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com> <20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org> <20131220140153.GC11295@suse.de> <1387608497.3119.17.camel@buesod1.americas.hpqcorp.net>
 <20131223004438.GA19388@lge.com> <20131223021118.GA2487@lge.com> <1388778945.2956.20.camel@buesod1.americas.hpqcorp.net> <20140106001938.GB696@lge.com> <1389010745.14953.5.camel@buesod1.americas.hpqcorp.net> <20140107015701.GB26726@lge.com>
 <1389062214.9937.0.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, aswin@hp.com

On Mon, 6 Jan 2014, Davidlohr Bueso wrote:

> > If Andrew agree, It would be great to merge 1-7 patches into mainline
> > before your mutex approach. There are some of clean-up patches and, IMO,
> > it makes the code more readable and maintainable, so it is worth to merge
> > separately.
> 
> Fine by me.
> 

It appears like patches 1-7 are still missing from linux-next, would you 
mind posting them in a series with your approach?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
