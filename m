Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id AA8D86B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 01:20:14 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so1446425pad.14
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 22:20:14 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id p3si12680609pbj.278.2014.01.22.22.20.11
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 22:20:13 -0800 (PST)
Date: Thu, 23 Jan 2014 15:21:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [LSF/MM TOPIC] volatile range: part 2
Message-ID: <20140123062128.GB14369@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>

Last year, there was discussion about volatile range but it seems
there wasn't no progress because John and I were stucked other
urgent works.

Recently, we modified many part of volatile range and submit
test code for volatile range anonymous part.

http://lwn.net/Articles/578761/

But still we didn't get indepth code review and many feedback.
It makes very hard to proceed that work.

I believe it's really nice concept and other OSes already similar
system call so lack of interesting from other MM guys is totally
my fault.

In this summit, I will summarize current status and known problems
I'm thinking so I hope lots of feedback and you guys will give a
time slot to review.

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
