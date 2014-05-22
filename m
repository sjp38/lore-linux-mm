Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id AC1376B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 13:23:11 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so2785553pbb.25
        for <linux-mm@kvack.org>; Thu, 22 May 2014 10:23:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hm7si521015pad.140.2014.05.22.10.23.10
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 10:23:10 -0700 (PDT)
Subject: Re: [PATCH 0/3] Shrinkers and proportional reclaim
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1400749779-24879-1-git-send-email-mgorman@suse.de>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 May 2014 10:22:42 -0700
Message-ID: <1400779362.2970.322.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Dave Chinner <david@fromorbit.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Thu, 2014-05-22 at 10:09 +0100, Mel Gorman wrote:
> This series is aimed at regressions noticed during reclaim activity. The
> first two patches are shrinker patches that were posted ages ago but never
> merged for reasons that are unclear to me. I'm posting them again to see if
> there was a reason they were dropped or if they just got lost. Dave?  Time?

As far as I remembered, I think Dave was planning to merge this as part
of his VFS scalability patch series.  Otherwise there wasn't any other
issues.

Thanks to Mel for looking at these patches and Yunhan for testing them.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
