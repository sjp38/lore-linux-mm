Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B64D56B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 05:04:37 -0500 (EST)
Date: Fri, 13 Jan 2012 10:04:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: __count_immobile_pages make sure the node is online
Message-ID: <20120113100432.GO4118@suse.de>
References: <20120111084802.GA16466@tiehlicka.suse.cz>
 <20120112111702.3b7f2fa2.kamezawa.hiroyu@jp.fujitsu.com>
 <20120112082722.GB1042@tiehlicka.suse.cz>
 <20120112173536.db529713.kamezawa.hiroyu@jp.fujitsu.com>
 <20120112092314.GC1042@tiehlicka.suse.cz>
 <20120112183323.1bb62f4d.kamezawa.hiroyu@jp.fujitsu.com>
 <20120112100521.GD1042@tiehlicka.suse.cz>
 <20120112111415.GH4118@suse.de>
 <20120112123555.GF1042@tiehlicka.suse.cz>
 <20120112132629.345e0e37.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120112132629.345e0e37.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Jan 12, 2012 at 01:26:29PM -0800, Andrew Morton wrote:
> On Thu, 12 Jan 2012 13:35:55 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 12-01-12 11:14:15, Mel Gorman wrote:
> > > On Thu, Jan 12, 2012 at 11:05:21AM +0100, Michal Hocko wrote:
> > 
> > > Be aware that this is not the version picked up by Andrew. It would
> > > not hurt to resend as V2 with a changelog and a note saying it replaces
> > > mm-fix-null-ptr-dereference-in-__count_immobile_pages.patch in mmotm.
> 
> They're rather different things? According to the changelogs,
> mm-fix-null-ptr-dereference-in-__count_immobile_pages.patch fixes a
> known-to-occur oops. 
> mm-__count_immobile_pages-make-sure-the-node-is-online.patch fixes a
> bug which might happen in the future if we change the node_zones layut?
> 

That's fine. I thought the second patch was so closely related that
they would be collapsed together and both sent to stable. There is no
particular advantage to doing this and keeping them separate is fine.

FWIW, my ack applied to both patches in that case.

> So I'm thinking that
> mm-fix-null-ptr-dereference-in-__count_immobile_pages.patch is 3.3 and
> -stable material, whereas this patch
> (mm-__count_immobile_pages-make-sure-the-node-is-online.patch) is 3.3
> material.  (Actually, it's 3.4 material which I shall stuff into 3.3
> because the amount of MM material which we're putting into 3.3 is just
> off the charts and I fear that 3.4 will be similar)
> 

Ok, sounds good. Thanks.

> > > This is just in case the wrong one gets merged due to this thread
> > > getting lost in the noise of Andrew's inbox.
> 
> It won't get lost, but there's a higher-than-usual chance of delays if
> the patch happens during the merge window: if I see a lengthy patch
> thread I'll move it into my to-apply folder for consideration later on.
> So I will look at it, but it might be after the merge window.  We can
> still apply a fix after the merge window of course, but this all might
> end up leaving buggy code in the tree for longer than we'd like.
> 

Understood.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
