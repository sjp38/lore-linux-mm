Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id A20306B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 05:41:09 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so526483eek.6
        for <linux-mm@kvack.org>; Wed, 07 May 2014 02:41:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si15806025eeg.211.2014.05.07.02.41.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 02:41:08 -0700 (PDT)
Date: Wed, 7 May 2014 10:41:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v3 6/6] mm, compaction: terminate async compaction when
 rescheduling
Message-ID: <20140507094105.GF23991@suse.de>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 06, 2014 at 07:22:52PM -0700, David Rientjes wrote:
> Async compaction terminates prematurely when need_resched(), see
> compact_checklock_irqsave().  This can never trigger, however, if the 
> cond_resched() in isolate_migratepages_range() always takes care of the 
> scheduling.
> 
> If the cond_resched() actually triggers, then terminate this pageblock scan for 
> async compaction as well.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
