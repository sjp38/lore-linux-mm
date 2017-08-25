Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAAB6B05C1
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:16:26 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id p12so11732974qkl.0
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 06:16:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 8si1064504qkp.409.2017.08.25.06.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 06:16:25 -0700 (PDT)
Date: Fri, 25 Aug 2017 15:16:15 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 0/3] Separate NUMA statistics from zone statistics
Message-ID: <20170825151615.4eb04cf4@redhat.com>
In-Reply-To: <20170825080437.wyikqunw6mtj22hu@techsingularity.net>
References: <1503568801-21305-1-git-send-email-kemi.wang@intel.com>
	<20170825080437.wyikqunw6mtj22hu@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Kemi Wang <kemi.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, brouer@redhat.com

On Fri, 25 Aug 2017 09:04:37 +0100
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Thu, Aug 24, 2017 at 05:59:58PM +0800, Kemi Wang wrote:
> > Each page allocation updates a set of per-zone statistics with a call to
> > zone_statistics(). As discussed in 2017 MM summit, these are a substantial
> > source of overhead in the page allocator and are very rarely consumed. This
> > significant overhead in cache bouncing caused by zone counters (NUMA
> > associated counters) update in parallel in multi-threaded page allocation
> > (pointed out by Dave Hansen).
> >   
> 
> For the series;
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> 

I'm very happy to see these issues being worked on, from our MM-summit
interactions. I would like to provide/have a:

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>

As I'm not sure an acked-by from me have any value/merit here ;-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
