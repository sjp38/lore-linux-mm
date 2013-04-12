Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 45C7A6B0027
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 05:34:28 -0400 (EDT)
Date: Fri, 12 Apr 2013 10:34:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd
 reclaims at each priority
Message-ID: <20130412093420.GG11656@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-2-git-send-email-mgorman@suse.de>
 <20130321155705.GA27848@cmpxchg.org>
 <514BA04D.2090002@gmail.com>
 <514BD56F.6050709@redhat.com>
 <5166510E.2050709@gmail.com>
 <51679FAE.7090504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51679FAE.7090504@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Will Huck <will.huckk@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 12, 2013 at 01:46:22PM +0800, Ric Mason wrote:
> Ping Rik, I also want to know the answer. ;-)

This question, like a *lot* of list traffic recently, is a "how long is a
piece of string" with hints that it is an important question but really
is just going to waste a developers time because the question lacks any
relevant meaning. The Inter-Reference Distance (IRD) is mentioned as a
problem but gives no context as to why it is perceived as a problem. IRD is
the distance in time or events between two references of the same page and
is a function of the workload and an arbitrary page, not the page reclaim
algorithm. A page algorithm may take IRD into account but IRD is not and
cannot be a "problem" so the question framing is already confusing.

Furthermore, the upsides and downsides of any given page reclaim algorithm
are complex but in most cases are discussed in the academic pages describing
them. People who are interested need to research and read these papers
and then see how it might apply to the algorithm implemented in Linux or
alternatively investigate what important workloads Linux treats badly
and addressing the problem. The result of such research (and patches)
is then a relevant discussion.

This question asks what the "downside" is versus anonymous pages.  To me
the question lacks any meaning because how can a page reclaim algorithm
"against" anonymous pages? As the question lacks meaning, answering it is
impossible and it is effectively asking a developer to write a small paper
to try and discover the meaning of the question before then answering it.

I do not speak for Rik but I at least am ignoring most of these questions
because there is not enough time in the day already. Pings are not
likely to change my opinion.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
