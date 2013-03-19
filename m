Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id B95CD6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 07:01:41 -0400 (EDT)
Date: Tue, 19 Mar 2013 11:01:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Message-ID: <20130319110137.GK2055@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-4-git-send-email-mgorman@suse.de>
 <5147D6A7.5060008@gmail.com>
 <20130319101428.GD2055@suse.de>
 <51483D63.4070904@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51483D63.4070904@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 19, 2013 at 06:26:43PM +0800, Simon Jeons wrote:
> >>>-		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> >>>-			break;
> >>>-	} while (--sc.priority >= 0);
> >>>+		if (order && sc.nr_reclaimed >= 2UL << order)
> >>>+			order = sc.order = 0;
> >>If order == 0 is meet, should we do defrag for it?
> >>
> >Compaction is unnecessary for order-0.
> >
> 
> I mean since order && sc.reclaimed >= 2UL << order, it is reclaimed
> for high order allocation, if order == 0 is meet, should we do
> defrag for it?
> 

I don't get this question at all. We do not defrag via compaction for
order-0 allocation requests because it makes no sense.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
