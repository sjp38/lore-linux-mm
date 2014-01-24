Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 076CD6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:42:20 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so3074186wgg.34
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 07:42:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez4si798724wjd.25.2014.01.24.07.42.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 07:42:17 -0800 (PST)
Date: Fri, 24 Jan 2014 15:42:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 8/9] numa,sched: rename variables in task_numa_fault
Message-ID: <20140124154214.GB4963@suse.de>
References: <1390342811-11769-1-git-send-email-riel@redhat.com>
 <1390342811-11769-9-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390342811-11769-9-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Tue, Jan 21, 2014 at 05:20:10PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> We track both the node of the memory after a NUMA fault, and the node
> of the CPU on which the fault happened. Rename the local variables in
> task_numa_fault to make things more explicit.
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
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
