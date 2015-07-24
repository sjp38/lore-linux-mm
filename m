Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 54E526B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:28:46 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so77647172wic.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:28:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ic1si6166755wid.77.2015.07.24.13.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 13:28:44 -0700 (PDT)
Message-ID: <1437769711.3298.55.camel@stgolabs.net>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 24 Jul 2015 13:28:31 -0700
In-Reply-To: <20150724171237.GC3458@Sligo.logfs.org>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
	 <20150724065959.GB4622@dhcp22.suse.cz>
	 <20150724171237.GC3458@Sligo.logfs.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Cc: Michal Hocko <mhocko@kernel.org>, Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

On Fri, 2015-07-24 at 10:12 -0700, JA?rn Engel wrote:
> On Fri, Jul 24, 2015 at 08:59:59AM +0200, Michal Hocko wrote:
> > On Thu 23-07-15 14:54:31, Spencer Baugh wrote:
> > > From: Joern Engel <joern@logfs.org>
> > > 
> > > ~150ms scheduler latency for both observed in the wild.
> > 
> > This is way to vague. Could you describe your problem somehow more,
> > please?
> > There are schduling points in the page allocator (when it triggers the
> > reclaim), why are those not sufficient? Or do you manage to allocate
> > many hugetlb pages without performing the reclaim and that leads to
> > soft lockups?
> 
> We don't use transparent hugepages - they cause too much latency.
> Instead we reserve somewhere around 3/4 or so of physical memory for
> hugepages.  "sysctl -w vm.nr_hugepages=100000" or something similar in a
> startup script.
> 
> Since it is early in boot we don't go through page reclaim.

Still, please be more verbose about what you _are_ encountering. Iow,
please have decent changelog in v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
