Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6DCA76B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 10:11:57 -0400 (EDT)
Date: Thu, 16 May 2013 15:11:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/9] Reduce system disruption due to kswapd V4
Message-ID: <20130516141151.GI11497@suse.de>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
 <20130515133748.5db2c6fb61c72ec61381d941@linux-foundation.org>
 <20130516103344.GF11497@suse.de>
 <20130516135428.GG13848@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130516135428.GG13848@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, May 16, 2013 at 03:54:28PM +0200, Michal Hocko wrote:
> On Thu 16-05-13 11:33:45, Mel Gorman wrote:
> [...]
> > swapin in this case is an indication as to whether we are swap trashing.
> > 	The closer the swapin/swapout ratio is to 0, the worse the
> 
> I guess you meant the ratio is closer to 1 not zero.

Damnit, yes! I was even thinking 1 at the time I was typing. It's not
like the keys are even near each other.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
