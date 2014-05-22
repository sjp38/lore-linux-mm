Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7484C6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 12:30:58 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so2850065eei.19
        for <linux-mm@kvack.org>; Thu, 22 May 2014 09:30:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si1545680eep.25.2014.05.22.09.30.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 09:30:57 -0700 (PDT)
Date: Thu, 22 May 2014 17:30:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] Shrinkers and proportional reclaim
Message-ID: <20140522163051.GJ23991@suse.de>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
 <20140522161416.GD25013@yliu-dev.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140522161416.GD25013@yliu-dev.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, May 23, 2014 at 12:14:16AM +0800, Yuanhan Liu wrote:
> On Thu, May 22, 2014 at 10:09:36AM +0100, Mel Gorman wrote:
> > This series is aimed at regressions noticed during reclaim activity. The
> > first two patches are shrinker patches that were posted ages ago but never
> > merged for reasons that are unclear to me. I'm posting them again to see if
> > there was a reason they were dropped or if they just got lost. Dave?  Time?
> > The last patch adjusts proportional reclaim. Yuanhan Liu, can you retest
> > the vm scalability test cases on a larger machine? Hugh, does this work
> > for you on the memcg test cases?
> 
> Sure, and here is the result. I applied these 3 patches on v3.15-rc6,
> and head commit is 60c10afd. e82e0561 is the old commit that introduced
> the regression.  The testserver has 512G memory and 120 CPU.
> 
> It's a simple result; if you need more data, I can gather them and send
> it to you tomorrow:
> 
> e82e0561        v3.15-rc6       60c10afd
> ----------------------------------------
> 18560785        12232122        38868453
>                 -34%            +109
> 
> As you can see, the performance is back, and it is way much better ;)
> 

Thanks a lot for that and the quick response. It is much appreciated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
