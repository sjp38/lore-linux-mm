Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 952876B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:04:46 -0400 (EDT)
Date: Wed, 31 Oct 2012 15:04:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd0: excessive CPU usage
Message-ID: <20121031150438.GK3888@suse.de>
References: <50770905.5070904@suse.cz>
 <119175.1349979570@turing-police.cc.vt.edu>
 <5077434D.7080008@suse.cz>
 <50780F26.7070007@suse.cz>
 <20121012135726.GY29125@suse.de>
 <507BDD45.1070705@suse.cz>
 <20121015110937.GE29125@suse.de>
 <508E5FD3.1060105@leemhuis.info>
 <20121030191843.GH3888@suse.de>
 <50910A99.5050707@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50910A99.5050707@leemhuis.info>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thorsten Leemhuis <fedora@leemhuis.info>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 31, 2012 at 12:25:13PM +0100, Thorsten Leemhuis wrote:
> On 30.10.2012 20:18, Mel Gorman wrote:
> >On Mon, Oct 29, 2012 at 11:52:03AM +0100, Thorsten Leemhuis wrote:
> >>On 15.10.2012 13:09, Mel Gorman wrote:
> >>>On Mon, Oct 15, 2012 at 11:54:13AM +0200, Jiri Slaby wrote:
> >>>>On 10/12/2012 03:57 PM, Mel Gorman wrote:
> >>>>>mm: vmscan: scale number of pages reclaimed by reclaim/compaction only in direct reclaim
> >>>>>Jiri Slaby reported the following:
> >[...]
> >>>>Yes, applying this instead of the revert fixes the issue as well.
> >>Just wondering, is there a reason why this patch wasn't applied to
> >>mainline? Did it simply fall through the cracks? Or am I missing
> >>something?
> >It's because a problem was reported related to the patch (off-list,
> >whoops). I'm waiting to hear if a second patch fixes the problem or not.
> 
> Anything in particular I should look out for while testing?
> 

Excessive reclaim, high CPU usage by kswapd, processes getting stick in
isolate_migratepages or isolate_freepages.

> >>I'm asking because I think I stil see the issue on
> >>3.7-rc2-git-checkout-from-friday. Seems Fedora rawhide users are
> >>hitting it, too:
> >>https://bugzilla.redhat.com/show_bug.cgi?id=866988
> >I like the steps to reproduce.
> 
> One of those cases where the bugzilla bug template was not very
> helpful or where it was not used as intended (you decide) :-)
> 

It wins at entertainment value if nothing else :)

> >Is step 3 profit?
> 
> Yes, but psst, don't tell anyone; step 4 (world domination! for
> real!) is also hidden to keep that part of the big plan a secret for
> now ;-)
> 

No doubt it's the default private comment #1 !

> >>Or are we seeing something different which just looks similar?  I can
> >>test the patch if it needs further testing, but from the discussion
> >>I got the impression that everything is clear and the patch ready
> >>for merging.
> >It could be the same issue. Can you test with the "mm: vmscan: scale
> >number of pages reclaimed by reclaim/compaction only in direct reclaim"
> >patch and the following on top please?
> 
> Built a vanilla mainline kernel with those two patches and installed
> it on the machine where I was seeing problems high kswapd0 load on
> 3.7-rc3. Ran it an hour yesterday and a few hours today; seems the
> patches fix the issue for me as kswapd behaves:
> 
> $ LC_ALL=C ps -aux | grep 'kswapd'
> root       62  0.0  0.0      0     0 ?      S    Oct30   0:05 [kswapd0]
> 
> So everything is looking fine again so far thx to the two patches
> -- hopefully it stays that way even after hitting "send" in my
> mailer in a few seconds.
> 

Ok, great. Keep an eye on it please. If Jiri Slaby reports similar
success then I'll collapse the two patches together and resend to
Andrew.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
