Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 7BABF6B0037
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 11:16:02 -0400 (EDT)
Date: Tue, 2 Apr 2013 16:15:58 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130402151558.GI32241@suse.de>
References: <20130402142717.GH32241@suse.de>
 <515AF348.7060209@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <515AF348.7060209@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, Apr 02, 2013 at 11:03:36PM +0800, Zheng Liu wrote:
> Hi Mel,
> 
> Thanks for reporting it.
> 
> On 04/02/2013 10:27 PM, Mel Gorman wrote:
> > I'm testing a page-reclaim-related series on my laptop that is partially
> > aimed at fixing long stalls when doing metadata-intensive operations on
> > low memory such as a git checkout. I've been running 3.9-rc2 with the
> > series applied but found that the interactive performance was awful even
> > when there was plenty of free memory.
> > 
> > I activated a monitor from mmtests that logs when a process is stuck for
> > a long time in D state and found that there are a lot of stalls in ext4.
> > The report first states that processes have been stalled for a total of
> > 6498 seconds on IO which seems like a lot. Here is a breakdown of the
> > recorded events.
> 
> In this merge window, we add a status tree as a extent cache.  Meanwhile
> a es_cache shrinker is registered to try to reclaim from this cache when
> we are under a high memory pressure. 

Ok.

> So I suspect that the root cause
> is this shrinker.  Could you please tell me how to reproduce this
> problem?  If I understand correctly, I can run mmtest to reproduce this
> problem, right?
> 

This is normal desktop usage with some development thrown in, nothing
spectacular but nothing obviously reproducible either unfortuantely. I
just noticed that some git operations were taking abnormally long, mutt
was very slow opening mail, applications like mozilla were very slow to
launch etc. and dug a little further. I haven't checked if regression
tests under mmtests captured something similar yet.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
