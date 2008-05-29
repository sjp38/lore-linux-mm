Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4T5766r018572
	for <linux-mm@kvack.org>; Thu, 29 May 2008 01:07:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4T575p8099762
	for <linux-mm@kvack.org>; Wed, 28 May 2008 23:07:05 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4T575kA032397
	for <linux-mm@kvack.org>; Wed, 28 May 2008 23:07:05 -0600
Date: Wed, 28 May 2008 22:07:03 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 05/23] hugetlb: multi hstate proc files
Message-ID: <20080529050703.GA27288@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.625669000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143452.625669000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:22 +1000], npiggin@suse.de wrote:
> Convert /proc output code over to report multiple hstates
> 
> I chose to just report the numbers in a row, in the hope 
> to minimze breakage of existing software. The "compat" page size
> is always the first number.

I'm assuming this is just copied from the old changelog, because as far
as I can tell, and from my quick testing just now with my sysfs patch,
hstates[0] is just whichever hugepage size is registered first. So that
either means by "compat" you meant the default on the current system
(which is only compatible with boots having the same order of boot-line
parameters) or we need to fix this patch to put HPAGE_SIZE (which we
haven't changed, per se) to be in hstates[0]. It might help to have a
helper macro called default_hstate (or a comment) [which I thought we
had in the beginnning of the patchset, but I see one of the intervening
patches removed it] indicating which state is the default when none is
specified.

The reason I bring this up is that I have my sysfs patchset in two
parts. First, I add the sysfs interface and then I remove the
multi-valued proc files. But for the latter, I rely on hstates[0] to be
the one we want to be presenting in proc. If that's not the case, how
should I be determining which hstate is the default? If that is the
case, shall I make the reverting patch also put the "right" value in
hstates[0]?

At the same time, my testing of the sysfs code appears successful still
and I will hopefully be able to post them in the morning.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
