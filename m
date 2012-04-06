Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id EB8FB6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 19:35:46 -0400 (EDT)
Received: by iajr24 with SMTP id r24so4990361iaj.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 16:35:46 -0700 (PDT)
Date: Fri, 6 Apr 2012 16:35:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] hugetlb: fix race condition in hugetlb_fault()
In-Reply-To: <20120406162618.3307a9bd.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1204061631160.3820@eggly.anvils>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com> <CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com> <201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com> <CAJd=RBBWx7uZcw=_oA06RVunPAGeFcJ7LY=RwFCyB_BreJb_kg@mail.gmail.com>
 <4F7887A5.3060700@tilera.com> <20120406152305.59408e35.akpm@linux-foundation.org> <alpine.LSU.2.00.1204061601370.3637@eggly.anvils> <20120406162618.3307a9bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 6 Apr 2012, Andrew Morton wrote:
> On Fri, 6 Apr 2012 16:10:13 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > The resulting patch is okay; but let's reassure Chris that his
> > original patch was better, before he conceded to make the get_page
> > and put_page unconditional, and added unnecessary detail of the race.
> > 
> 
> Yes, the v1 patch was better.  No reason was given for changing it?

I think Chris was aiming to be a model citizen, and followed review
suggestions that he would actually have done better to resist.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
