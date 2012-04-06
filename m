Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 93E746B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 18:23:07 -0400 (EDT)
Date: Fri, 6 Apr 2012 15:23:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] hugetlb: fix race condition in hugetlb_fault()
Message-Id: <20120406152305.59408e35.akpm@linux-foundation.org>
In-Reply-To: <4F7887A5.3060700@tilera.com>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
	<CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
	<201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com>
	<CAJd=RBBWx7uZcw=_oA06RVunPAGeFcJ7LY=RwFCyB_BreJb_kg@mail.gmail.com>
	<4F7887A5.3060700@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Sun, 1 Apr 2012 12:51:49 -0400
Chris Metcalf <cmetcalf@tilera.com> wrote:

> >> Cc: stable@kernel.org
> > Let Andrew do the stable work, ok?
> 
> Fair point.  I'm used to adding the Cc myself for things I push through the
> arch/tile tree.  This of course does make more sense to go through Andrew,
> so I'll remove it.

No, please do add the stable tag if you think it is needed.  And ensure
that the changelog explains why a backport is needed, by describing
the user-visible effects of the bug.

Tree-owners regularly forget to wonder if a patch should be backported
and we end up failing to backport patches which should have been
backported.  If we have more people flagging backport patches, fewer
patches will fall through the cracks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
