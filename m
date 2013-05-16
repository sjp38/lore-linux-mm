Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1B5EB6B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 09:54:31 -0400 (EDT)
Date: Thu, 16 May 2013 15:54:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/9] Reduce system disruption due to kswapd V4
Message-ID: <20130516135428.GG13848@dhcp22.suse.cz>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
 <20130515133748.5db2c6fb61c72ec61381d941@linux-foundation.org>
 <20130516103344.GF11497@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130516103344.GF11497@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 16-05-13 11:33:45, Mel Gorman wrote:
[...]
> swapin in this case is an indication as to whether we are swap trashing.
> 	The closer the swapin/swapout ratio is to 0, the worse the

I guess you meant the ratio is closer to 1 not zero.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
