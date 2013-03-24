Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 158BC6B0002
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 15:00:13 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id c50so2978388eek.2
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 12:00:11 -0700 (PDT)
Message-ID: <514F4D37.5030304@suse.cz>
Date: Sun, 24 Mar 2013 20:00:07 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8] Reduce system disruption due to kswapd
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/17/2013 02:04 PM, Mel Gorman wrote:
> Kswapd and page reclaim behaviour has been screwy in one way or the other
> for a long time. Very broadly speaking it worked in the far past because
> machines were limited in memory so it did not have that many pages to scan
> and it stalled congestion_wait() frequently to prevent it going completely
> nuts. In recent times it has behaved very unsatisfactorily with some of
> the problems compounded by the removal of stall logic and the introduction
> of transparent hugepage support with high-order reclaims.
> 
> There are many variations of bugs that are rooted in this area. One example
> is reports of a large copy operations or backup causing the machine to
> grind to a halt or applications pushed to swap. Sometimes in low memory
> situations a large percentage of memory suddenly gets reclaimed. In other
> cases an application starts and kswapd hits 100% CPU usage for prolonged
> periods of time and so on. There is now talk of introducing features like
> an extra free kbytes tunable to work around aspects of the problem instead
> of trying to deal with it. It's compounded by the problem that it can be
> very workload and machine specific.
> 
> This RFC is aimed at investigating if kswapd can be address these various
> problems in a relatively straight-forward fashion without a fundamental
> rewrite.
> 
> Patches 1-2 limits the number of pages kswapd reclaims while still obeying
> 	the anon/file proportion of the LRUs it should be scanning.

Hi,

patch 1 does not apply (on the top of -next), so I can't test this :(.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
