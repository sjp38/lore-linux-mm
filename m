Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A3A606B003A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 16:25:41 -0400 (EDT)
Date: Mon, 08 Apr 2013 16:25:29 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365452729-dczpcd7w-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <515F4D9A.3060009@gmail.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F4D9A.3060009@gmail.com>
Subject: Re: [PATCH 07/10] mbind: add hugepage migration code to mbind()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

On Fri, Apr 05, 2013 at 06:18:02PM -0400, KOSAKI Motohiro wrote:
> > @@ -1277,14 +1279,10 @@ static long do_mbind(unsigned long start, unsigned long len,
> >  	if (!err) {
> >  		int nr_failed = 0;
> >  
> > -		if (!list_empty(&pagelist)) {
> > -			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
> > -			nr_failed = migrate_pages(&pagelist, new_vma_page,
> > +		WARN_ON_ONCE(flags & MPOL_MF_LAZY);
> 
> ???
> MPOL_MF_LAZY always output warn? It seems really insane.

So I'll stop replacing this block into migrate_movable_pages() and
leave this WARN as it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
