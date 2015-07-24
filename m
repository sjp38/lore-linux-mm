Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 977506B0256
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:12:45 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so16579930pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:12:45 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id 4si2295994pdf.72.2015.07.24.10.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 10:12:44 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so17248286pab.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:12:44 -0700 (PDT)
Date: Fri, 24 Jul 2015 10:12:37 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
Message-ID: <20150724171237.GC3458@Sligo.logfs.org>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
 <20150724065959.GB4622@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150724065959.GB4622@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

On Fri, Jul 24, 2015 at 08:59:59AM +0200, Michal Hocko wrote:
> On Thu 23-07-15 14:54:31, Spencer Baugh wrote:
> > From: Joern Engel <joern@logfs.org>
> > 
> > ~150ms scheduler latency for both observed in the wild.
> 
> This is way to vague. Could you describe your problem somehow more,
> please?
> There are schduling points in the page allocator (when it triggers the
> reclaim), why are those not sufficient? Or do you manage to allocate
> many hugetlb pages without performing the reclaim and that leads to
> soft lockups?

We don't use transparent hugepages - they cause too much latency.
Instead we reserve somewhere around 3/4 or so of physical memory for
hugepages.  "sysctl -w vm.nr_hugepages=100000" or something similar in a
startup script.

Since it is early in boot we don't go through page reclaim.

Jorn

--
Everything should be made as simple as possible, but not simpler.
-- Albert Einstein

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
