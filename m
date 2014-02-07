Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id C27CE6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:51:21 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so1522895eek.10
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:51:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k3si8056639eep.183.2014.02.07.04.51.19
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 04:51:20 -0800 (PST)
Message-ID: <52F4D6BE.5060609@redhat.com>
Date: Fri, 07 Feb 2014 07:51:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] mm: Mark function as static in compaction.c
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, josh@joshtriplett.org

On 02/07/2014 07:01 AM, Rashika Kheria wrote:
> Mark function as static in compaction.c because it is not used outside
> this file.
> 
> This eliminates the following warning from mm/compaction.c:
> mm/compaction.c:1190:9: warning: no previous prototype for a??sysfs_compact_nodea?? [-Wmissing-prototypes
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
