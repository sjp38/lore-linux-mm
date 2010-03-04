Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1EEDF6B007E
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 04:13:13 -0500 (EST)
Received: by pxi26 with SMTP id 26so837183pxi.1
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 01:13:15 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 4 Mar 2010 14:43:10 +0530
Message-ID: <9bde694e1003040113k3b573957h1b831c8d25205d22@mail.gmail.com>
Subject: kmemleak issue on ARM target
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: catalin.marinas@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Catalin Marinas ,


W am facing one issue on ARM target, we have 512 MB ram on our target,
we port your patch of
kmemleak(http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg11830.html)

We are facing problem in DEBUG_KMEMLEAK_EARLY_LOG_SIZE we cannot
increase its size above 1000 because of our kernel Image size for
embedded board
has some limit that if it increase we cannot execute it. so is there
any implementaion possible using vmalloc and not statically allocating
the log of array or else any suggestion.

kind regards
Naveen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
