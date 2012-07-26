Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id BFACD6B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 19:53:00 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Thu, 26 Jul 2012 17:52:59 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id CC7743E4003D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 23:52:43 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6QNqio4264358
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 17:52:44 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6QNqgm8014183
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 17:52:44 -0600
Message-ID: <5011D845.4090202@linaro.org>
Date: Thu, 26 Jul 2012 16:52:37 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] [RFC] Add volatile range management code
References: <1343346546-53230-1-git-send-email-john.stultz@linaro.org> <1343346546-53230-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1343346546-53230-2-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/26/2012 04:49 PM, John Stultz wrote:
> This patch provides the volatile range management code
> that filesystems can utilize when implementing
> FALLOC_FL_MARK_VOLATILE.

Bah. Sorry for the noise here.  Wanted Dave's thoughts on an unfinished 
patchset and forgot I had Cc's in some of the patches.

Ignore for now, hopefully I'll have something real I can send out soon.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
