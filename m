Date: Wed, 23 Jul 2008 15:29:24 -0400
From: Rik van Riel <riel@surriel.com>
Subject: Re: [RFC][PATCH -mm] vmscan: fix swapout on sequential IO
Message-ID: <20080723152924.752339dd@bree.surriel.com>
In-Reply-To: <87zlo8mo7p.fsf@saeurebad.de>
References: <20080723144115.72803eb8@bree.surriel.com>
	<87zlo8mo7p.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jul 2008 20:48:10 +0200
Johannes Weiner <hannes@saeurebad.de> wrote:

> > -			zone->lru[l].nr_scan += scan + 1;
> > +			zone->lru[l].nr_scan += scan + force_scan;
> 
> The accumulation aspect is not gone, though.  If the system has reached
> the force-scan priority swap_cluster_max times, the next scan, even if
> long after the last scan, will scan bogus lists.

Which I suspect is the desired behaviour.

Better go out of balance a little, than risk an OOM kill.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
