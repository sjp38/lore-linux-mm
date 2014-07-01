Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 690476B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 04:02:10 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so7296688wib.0
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 01:02:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu9si13857581wib.74.2014.07.01.01.02.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 01:02:09 -0700 (PDT)
Date: Tue, 1 Jul 2014 09:02:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-ID: <20140701080205.GT10819@suse.de>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
 <1404146883-21414-5-git-send-email-mgorman@suse.de>
 <20140630141404.e09bdb5fa6a879d17c4556b1@linux-foundation.org>
 <20140630215121.GQ10819@suse.de>
 <20140630150914.6db3805c28c60283deb94206@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140630150914.6db3805c28c60283deb94206@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jun 30, 2014 at 03:09:14PM -0700, Andrew Morton wrote:
> On Mon, 30 Jun 2014 22:51:21 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > > That's a large change in system time.  Does this all include kswapd
> > > activity?
> > > 
> > 
> > I don't have a profile to quantify that exactly. It takes 7 hours to
> > complete a test on that machine in this configuration
> 
> That's nuts.  Why should measuring this require more than a few minutes?

That's how long the full test takes to complete for each part of the IO
test. Profiling a subsection of it will miss some parts with no
guarantee the sampled subset is representative. Profiling for smaller
amounts of IO so the test completes quickly does not guarantee that the
sample is representative. Reducing the size of memory of the machine
using any tricks is also not representative etc.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
