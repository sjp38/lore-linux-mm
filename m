Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B43E16B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 11:03:45 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kp14so342518pab.36
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 08:03:45 -0700 (PDT)
Message-ID: <515AF348.7060209@gmail.com>
Date: Tue, 02 Apr 2013 23:03:36 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
MIME-Version: 1.0
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
References: <20130402142717.GH32241@suse.de>
In-Reply-To: <20130402142717.GH32241@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

Hi Mel,

Thanks for reporting it.

On 04/02/2013 10:27 PM, Mel Gorman wrote:
> I'm testing a page-reclaim-related series on my laptop that is partially
> aimed at fixing long stalls when doing metadata-intensive operations on
> low memory such as a git checkout. I've been running 3.9-rc2 with the
> series applied but found that the interactive performance was awful even
> when there was plenty of free memory.
> 
> I activated a monitor from mmtests that logs when a process is stuck for
> a long time in D state and found that there are a lot of stalls in ext4.
> The report first states that processes have been stalled for a total of
> 6498 seconds on IO which seems like a lot. Here is a breakdown of the
> recorded events.

In this merge window, we add a status tree as a extent cache.  Meanwhile
a es_cache shrinker is registered to try to reclaim from this cache when
we are under a high memory pressure.  So I suspect that the root cause
is this shrinker.  Could you please tell me how to reproduce this
problem?  If I understand correctly, I can run mmtest to reproduce this
problem, right?

Thanks,
						- Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
