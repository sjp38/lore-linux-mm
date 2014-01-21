Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0446B0037
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 11:15:23 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so3896993eak.30
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 08:15:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y48si10538946eew.100.2014.01.21.08.15.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 08:15:21 -0800 (PST)
Date: Tue, 21 Jan 2014 16:15:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/6] numa,sched: do statistics calculation using local
 variables only
Message-ID: <20140121161518.GM4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-7-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390245667-24193-7-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 20, 2014 at 02:21:07PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> The current code in task_numa_placement calculates the difference
> between the old and the new value, but also temporarily stores half
> of the old value in the per-process variables.
> 
> The NUMA balancing code looks at those per-process variables, and
> having other tasks temporarily see halved statistics could lead to
> unwanted numa migrations. This can be avoided by doing all the math
> in local variables.
> 
> This change also simplifies the code a little.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
