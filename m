Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 8C4A06B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 20:06:45 -0400 (EDT)
Date: Mon, 18 Mar 2013 20:06:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1363651595-ewr7efx1-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130318153300.GR10192@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130318152224.GQ10192@dhcp22.suse.cz>
 <20130318153300.GR10192@dhcp22.suse.cz>
Subject: Re: [PATCH 2/9] migrate: make core migration code aware of hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Mon, Mar 18, 2013 at 04:33:00PM +0100, Michal Hocko wrote:
> On Mon 18-03-13 16:22:24, Michal Hocko wrote:
> > On Thu 21-02-13 14:41:41, Naoya Horiguchi wrote:
> > [...]
> > > diff --git v3.8.orig/include/linux/mempolicy.h v3.8/include/linux/mempolicy.h
> > > index 0d7df39..2e475b5 100644
> > > --- v3.8.orig/include/linux/mempolicy.h
> > > +++ v3.8/include/linux/mempolicy.h
> > > @@ -173,7 +173,7 @@ extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
> > >  /* Check if a vma is migratable */
> > >  static inline int vma_migratable(struct vm_area_struct *vma)
> > >  {
> > > -	if (vma->vm_flags & (VM_IO | VM_HUGETLB | VM_PFNMAP))
> > > +	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
> > >  		return 0;
> > 
> > Is this safe? At least check_*_range don't seem to be hugetlb aware.
> 
> Ohh, they become in 5/9. Should that one be reordered then?

OK, I'll shift this change after 5/9 patch.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
