Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 058E56B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:09:34 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id a1so5493108wgh.20
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:09:34 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ku4si43631161wjb.157.2014.07.10.05.09.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:09:34 -0700 (PDT)
Date: Thu, 10 Jul 2014 08:09:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/6] mm: vmscan: Only update per-cpu thresholds for
 online CPU
Message-ID: <20140710120931.GL29639@cmpxchg.org>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404893588-21371-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Wed, Jul 09, 2014 at 09:13:06AM +0100, Mel Gorman wrote:
> When kswapd is awake reclaiming, the per-cpu stat thresholds are
> lowered to get more accurate counts to avoid breaching watermarks.  This
> threshold update iterates over all possible CPUs which is unnecessary.
> Only online CPUs need to be updated. If a new CPU is onlined,
> refresh_zone_stat_thresholds() will set the thresholds correctly.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
