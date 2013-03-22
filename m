Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C99316B0037
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 10:37:33 -0400 (EDT)
Date: Fri, 22 Mar 2013 14:37:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/8] Reduce system disruption due to kswapd
Message-ID: <20130322143727.GA578@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1363525456-10448-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Damien Wyart <damien.wyart@gmail.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 01:04:06PM +0000, Mel Gorman wrote:
> Kswapd and page reclaim behaviour has been screwy in one way or the other
> for a long time. Very broadly speaking it worked in the far past because
> machines were limited in memory so it did not have that many pages to scan
> and it stalled congestion_wait() frequently to prevent it going completely
> nuts. In recent times it has behaved very unsatisfactorily with some of
> the problems compounded by the removal of stall logic and the introduction
> of transparent hugepage support with high-order reclaims.
> 

With the current set of feedback the series as it currently stands for
me is located here

git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git mm-vmscan-limit-reclaim-v2r7

I haven't tested this version myself yet but others might be interested.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
