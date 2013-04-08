Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 640796B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 16:21:39 -0400 (EDT)
Date: Mon, 08 Apr 2013 16:21:26 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365452486-arj4q4xd-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <515F3F5C.2090709@gmail.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F3F5C.2090709@gmail.com>
Subject: Re: [PATCH 05/10] migrate: add hugepage migration code to
 migrate_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

On Fri, Apr 05, 2013 at 05:17:16PM -0400, KOSAKI Motohiro wrote:
> (3/22/13 4:23 PM), Naoya Horiguchi wrote:
> > This patch extends check_range() to handle vma with VM_HUGETLB set.
> > We will be able to migrate hugepage with migrate_pages(2) after
> > applying the enablement patch which comes later in this series.
> > 
> > Note that for larger hugepages (covered by pud entries, 1GB for
> > x86_64 for example), we simply skip it now.
> 
> check_range() has largely duplication with mm_walk and it is quirk subset.
> Instead of, could you replace them to mm_walk and enhance/cleanup mm_walk?

OK, I'll try this.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
