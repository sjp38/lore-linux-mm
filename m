Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 1F8396B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 18:28:35 -0400 (EDT)
Date: Mon, 30 Jul 2012 15:28:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Revert
 "hugetlb: avoid taking i_mmap_mutex in unmap_single_vma() for hugetlb"
Message-Id: <20120730152832.f27152d0.akpm@linux-foundation.org>
In-Reply-To: <877gtp5dnr.fsf@skywalker.in.ibm.com>
References: <1343385965-7738-1-git-send-email-mgorman@suse.de>
	<1343385965-7738-2-git-send-email-mgorman@suse.de>
	<877gtp5dnr.fsf@skywalker.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 27 Jul 2012 22:45:04 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> >
> > Unless Aneesh has another reason for the patch, it should be reverted
> > to preserve hugetlb page sharing locking.
> >
> 
> I guess we want to take this patch as a revert patch rather than
> dropping the one in -mm. That would help in documenting the i_mmap_mutex
> locking details in commit message. Or may be we should add necessary
> comments around the locking ?

Code comments would be better if possible - we shouldn't force people to
dig around in git history to understand small code snippets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
