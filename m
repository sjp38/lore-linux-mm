Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 666F96810B7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:04:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z132so1739802wmg.9
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 01:04:39 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id v9si6463632edc.529.2017.08.25.01.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 01:04:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id C8A711C15FF
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:04:37 +0100 (IST)
Date: Fri, 25 Aug 2017 09:04:37 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 0/3] Separate NUMA statistics from zone statistics
Message-ID: <20170825080437.wyikqunw6mtj22hu@techsingularity.net>
References: <1503568801-21305-1-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1503568801-21305-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, Aug 24, 2017 at 05:59:58PM +0800, Kemi Wang wrote:
> Each page allocation updates a set of per-zone statistics with a call to
> zone_statistics(). As discussed in 2017 MM summit, these are a substantial
> source of overhead in the page allocator and are very rarely consumed. This
> significant overhead in cache bouncing caused by zone counters (NUMA
> associated counters) update in parallel in multi-threaded page allocation
> (pointed out by Dave Hansen).
> 

For the series;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
