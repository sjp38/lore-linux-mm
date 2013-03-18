Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 74FF96B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 11:33:02 -0400 (EDT)
Date: Mon, 18 Mar 2013 16:33:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/9] migrate: make core migration code aware of hugepage
Message-ID: <20130318153300.GR10192@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130318152224.GQ10192@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130318152224.GQ10192@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Mon 18-03-13 16:22:24, Michal Hocko wrote:
> On Thu 21-02-13 14:41:41, Naoya Horiguchi wrote:
> [...]
> > diff --git v3.8.orig/include/linux/mempolicy.h v3.8/include/linux/mempolicy.h
> > index 0d7df39..2e475b5 100644
> > --- v3.8.orig/include/linux/mempolicy.h
> > +++ v3.8/include/linux/mempolicy.h
> > @@ -173,7 +173,7 @@ extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
> >  /* Check if a vma is migratable */
> >  static inline int vma_migratable(struct vm_area_struct *vma)
> >  {
> > -	if (vma->vm_flags & (VM_IO | VM_HUGETLB | VM_PFNMAP))
> > +	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
> >  		return 0;
> 
> Is this safe? At least check_*_range don't seem to be hugetlb aware.

Ohh, they become in 5/9. Should that one be reordered then?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
