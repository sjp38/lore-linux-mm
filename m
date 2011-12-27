Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BB4846B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 18:51:33 -0500 (EST)
Date: Tue, 27 Dec 2011 15:51:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hugetlb: avoid bogus counter of surplus huge page
Message-Id: <20111227155132.d64fd6d8.akpm@linux-foundation.org>
In-Reply-To: <20111227125701.GG5344@tiehlicka.suse.cz>
References: <CAJd=RBCS3-PoFa3FUVwhiznPTQH5xq7fTYa3m01a0-buACQbCA@mail.gmail.com>
	<20111227125701.GG5344@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Tue, 27 Dec 2011 13:57:01 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 23-12-11 21:38:38, Hillf Danton wrote:
> > From: Hillf Danton <dhillf@gmail.com>
> > Subject: [PATCH] mm: hugetlb: avoid bogus counter of surplus huge page
> > 
> > If we have to hand back the newly allocated huge page to page allocator,
> > for any reason, the changed counter should be recovered.
> > 
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Hillf Danton <dhillf@gmail.com>
> 
> Broken since 2.6.27 (caff3a2c: hugetlb: call arch_prepare_hugepage() for
> surplus pages) so a stable material

afacit only s390 is affected, and s390's page_table_alloc() is fairly
immortal, using GFP_KERNEL|__GFP_REPEAT.

So unless Martin and Heiko disagree, I think we can merge this in 3.3-rc1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
