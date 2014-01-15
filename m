Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 036D46B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 23:54:12 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so632835pab.1
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:54:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sj5si2493042pab.255.2014.01.14.20.54.11
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 20:54:11 -0800 (PST)
Date: Tue, 14 Jan 2014 20:56:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-Id: <20140114205603.f4fd2678.akpm@linux-foundation.org>
In-Reply-To: <1389760669.4971.31.camel@buesod1.americas.hpqcorp.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, aswin@hp.com

On Tue, 14 Jan 2014 20:37:49 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Tue, 2014-01-14 at 19:08 -0800, David Rientjes wrote:
> > On Mon, 6 Jan 2014, Davidlohr Bueso wrote:
> > 
> > > > If Andrew agree, It would be great to merge 1-7 patches into mainline
> > > > before your mutex approach. There are some of clean-up patches and, IMO,
> > > > it makes the code more readable and maintainable, so it is worth to merge
> > > > separately.
> > > 
> > > Fine by me.
> > > 
> > 
> > It appears like patches 1-7 are still missing from linux-next, would you 
> > mind posting them in a series with your approach?
> 
> I haven't looked much into patches 4-7, but at least the first three are
> ok. I was waiting for Andrew to take all seven for linux-next and then
> I'd rebase my approach on top. Anyway, unless Andrew has any
> preferences, if by later this week they're not picked up, I'll resend
> everything.

Well, we're mainly looking for bugfixes this last in the cycle. 
"[PATCH v3 03/14] mm, hugetlb: protect region tracking via newly
introduced resv_map lock" fixes a bug, but I'd assumed that it depended
on earlier patches.  If we think that one is serious then it would be
better to cook up a minimal fix which is backportable into 3.12 and
eariler?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
