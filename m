Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 871326B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 15:50:55 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so1655045pab.6
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 12:50:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fv4si4776720pbd.242.2014.01.15.12.50.53
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 12:50:54 -0800 (PST)
Date: Wed, 15 Jan 2014 12:50:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-Id: <20140115125051.d533309988175abda67cab23@linux-foundation.org>
In-Reply-To: <1389818820.17932.7.camel@buesod1.americas.hpqcorp.net>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com>
	<20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org>
	<20131220140153.GC11295@suse.de>
	<1387608497.3119.17.camel@buesod1.americas.hpqcorp.net>
	<20131223004438.GA19388@lge.com>
	<20131223021118.GA2487@lge.com>
	<1388778945.2956.20.camel@buesod1.americas.hpqcorp.net>
	<20140106001938.GB696@lge.com>
	<1389010745.14953.5.camel@buesod1.americas.hpqcorp.net>
	<20140107015701.GB26726@lge.com>
	<1389062214.9937.0.camel@buesod1.americas.hpqcorp.net>
	<alpine.DEB.2.02.1401141906350.451@chino.kir.corp.google.com>
	<1389760669.4971.31.camel@buesod1.americas.hpqcorp.net>
	<20140114205603.f4fd2678.akpm@linux-foundation.org>
	<1389818820.17932.7.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, aswin@hp.com

On Wed, 15 Jan 2014 12:47:00 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:

> > Well, we're mainly looking for bugfixes this last in the cycle. 
> > "[PATCH v3 03/14] mm, hugetlb: protect region tracking via newly
> > introduced resv_map lock" fixes a bug, but I'd assumed that it depended
> > on earlier patches. 
> 
> It doesn't seem to depend on anything. All 1-7 patches apply cleanly on
> linux-next, the last change to mm/hugetlb.c was commit 3ebac7fa (mm:
> dump page when hitting a VM_BUG_ON using VM_BUG_ON_PAGE).
> 
> >  If we think that one is serious then it would be
> > better to cook up a minimal fix which is backportable into 3.12 and
> > eariler?
> 
> I don't think it's too serious, afaik it's a theoretical race and I
> haven't seen any bug reports for it. So we can probably just wait for
> 3.14, as you say, it's already late in the cycle anyways.

OK, thanks.

> Just let me
> know what you want to do so we can continue working on the actual
> performance issue.

A resend after -rc1 would suit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
