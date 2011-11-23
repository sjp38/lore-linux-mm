Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id F1B086B00C2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 10:57:14 -0500 (EST)
Date: Wed, 23 Nov 2011 15:57:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/7] mm: compaction: Introduce sync-light migration for
 use by compaction
Message-ID: <20111123155707.GP19415@suse.de>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
 <1321900608-27687-8-git-send-email-mgorman@suse.de>
 <1321945011.22361.335.camel@sli10-conroe>
 <CAPQyPG4DQCxDah5VYMU6PNgeuD_3WJ-zm8XpL7V7BK8hAF8OJg@mail.gmail.com>
 <20111123110041.GM19415@suse.de>
 <CAPQyPG588_q1diT8KyPirUD9MLME6SanO-cSw1twzhFiTBWgCw@mail.gmail.com>
 <20111123134512.GN19415@suse.de>
 <CAPQyPG6b-MiysHnEadWRX729_q7G=_mYozSR+OatS-TLs_Sw_Q@mail.gmail.com>
 <20111123150810.GO19415@suse.de>
 <CAPQyPG58cjEQ8jPFhxGB6URcFoNt=NBC1L+T8aEWVUtPfBNh-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAPQyPG58cjEQ8jPFhxGB6URcFoNt=NBC1L+T8aEWVUtPfBNh-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 23, 2011 at 11:23:19PM +0800, Nai Xia wrote:
> > <SNIP>
> > This would be functionally equivalent and satisfy THP users
> > but I do not see it as being easier to understand or easier
> > to maintain than updating the API. If someone in the future
> > wanted to use migration without significant stalls without
> > being PF_MEMALLOC, they would need to update the API like this.
> > There are no users like this today but automatic NUMA migration
> > might want to leverage something like MIGRATE_SYNC_LIGHT
> > (http://comments.gmane.org/gmane.linux.kernel.mm/70239)
> 
> I see.
> So could I say that might be the time and users for my suggestion of
> page uptodate check to fit into?
> 

Yes, at that point checking for PageUptodate may be necessary depending
on their requirements.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
