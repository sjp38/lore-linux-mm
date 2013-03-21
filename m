Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 4741D6B0027
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:07:39 -0400 (EDT)
Date: Thu, 21 Mar 2013 18:07:35 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 09/10] mm: vmscan: Check if kswapd should writepage once
 per priority
Message-ID: <20130321180735.GN1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-10-git-send-email-mgorman@suse.de>
 <20130321165600.GV6094@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130321165600.GV6094@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 21, 2013 at 05:58:37PM +0100, Michal Hocko wrote:
> On Sun 17-03-13 13:04:15, Mel Gorman wrote:
> > Currently kswapd checks if it should start writepage as it shrinks
> > each zone without taking into consideration if the zone is balanced or
> > not. This is not wrong as such but it does not make much sense either.
> > This patch checks once per priority if kswapd should be writing pages.
> 
> Except it is not once per priority strictly speaking...  It doesn't make
> any difference though.
> 

Whoops, at one point during development it really was once per priority
which was always raised. I reworded it to "once per pgdat scan".

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
