Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5CE266B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 19:26:21 -0400 (EDT)
Date: Fri, 6 Apr 2012 16:26:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] hugetlb: fix race condition in hugetlb_fault()
Message-Id: <20120406162618.3307a9bd.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1204061601370.3637@eggly.anvils>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
	<CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
	<201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com>
	<CAJd=RBBWx7uZcw=_oA06RVunPAGeFcJ7LY=RwFCyB_BreJb_kg@mail.gmail.com>
	<4F7887A5.3060700@tilera.com>
	<20120406152305.59408e35.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1204061601370.3637@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 6 Apr 2012 16:10:13 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Fri, 6 Apr 2012, Andrew Morton wrote:
> > On Sun, 1 Apr 2012 12:51:49 -0400
> > Chris Metcalf <cmetcalf@tilera.com> wrote:
> > 
> > > >> Cc: stable@kernel.org
> > > > Let Andrew do the stable work, ok?
> > > 
> > > Fair point.  I'm used to adding the Cc myself for things I push through the
> > > arch/tile tree.  This of course does make more sense to go through Andrew,
> > > so I'll remove it.
> > 
> > No, please do add the stable tag if you think it is needed.  And ensure
> > that the changelog explains why a backport is needed, by describing
> > the user-visible effects of the bug.
> > 
> > Tree-owners regularly forget to wonder if a patch should be backported
> > and we end up failing to backport patches which should have been
> > backported.  If we have more people flagging backport patches, fewer
> > patches will fall through the cracks.
> 
> The resulting patch is okay; but let's reassure Chris that his
> original patch was better, before he conceded to make the get_page
> and put_page unconditional, and added unnecessary detail of the race.
> 

Yes, the v1 patch was better.  No reason was given for changing it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
