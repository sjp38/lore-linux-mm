Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 0F2876B0044
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 14:27:48 -0400 (EDT)
Date: Fri, 7 Sep 2012 11:27:15 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: steering allocations to particular parts of memory
Message-ID: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: dan.magenheimer@oracle.com, linux-mm@kvack.org

I am looking for a way to steer allocations (these may be
by either userspace or the kernel) to or away from particular
ranges of memory. The reason for this is that some parts of
memory are different from others (i.e. some memory may be
faster/slower). For instance there may be 500M of "fast"
memory and 1500M of "slower" memory on a 2G platform.

At the memory mini-summit last week, it was mentioned
that the Super-H architecture was using NUMA for this
purpose, which was considered to be an very bad thing
to do -- we have ported NUMA to ARM here (as an experiment)
and agree that NUMA doesn't work well for solving this problem.

After the NUMA discussion, I spoke briefly to you and asked
you what a good approach would be. You thought that something
based on transcendent memory (which I am somewhat familiar
with, having built something based upon it which can be used either
as contiguous memory or as clean cache) might work, but
you didn't supply any details.

At the time, you asked me to email you about this and copy
Dan and the linux-mm mailing list, where hopefully you or Dan
might be able to explain how this would work.

Thanks.

Larry Bassel

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
