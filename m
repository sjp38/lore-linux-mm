Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 616A36B0082
	for <linux-mm@kvack.org>; Sun, 27 May 2012 16:08:24 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 27 May 2012 19:48:18 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4RK13l65439884
	for <linux-mm@kvack.org>; Mon, 28 May 2012 06:01:04 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4RK8ARw006466
	for <linux-mm@kvack.org>; Mon, 28 May 2012 06:08:11 +1000
Date: Mon, 28 May 2012 01:37:57 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V6 03/14] hugetlbfs: Add an inline helper for finding
 hstate index
Message-ID: <20120527200757.GA7631@skywalker.linux.vnet.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1334573091-18602-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1205241420410.24113@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205241420410.24113@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Thu, May 24, 2012 at 02:22:27PM -0700, David Rientjes wrote:
> On Mon, 16 Apr 2012, Aneesh Kumar K.V wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > Add an inline helper and use it in the code.
> > 
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> I like the helper function, but you missed using it in 
> hugetlb_init().
> 

Will do this as an add on patc on top

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4b90dd5..58eead5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1891,7 +1891,7 @@ static int __init hugetlb_init(void)
 		if (!size_to_hstate(default_hstate_size))
 			hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
 	}
-	default_hstate_idx = size_to_hstate(default_hstate_size) - hstates;
+	default_hstate_idx = hstate_index(size_to_hstate(default_hstate_size));
 	if (default_hstate_max_huge_pages)
 		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
