Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 840456B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 08:04:17 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id d17so1539738eek.36
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 05:04:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x43si8083711eey.250.2014.02.07.05.04.15
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 05:04:16 -0800 (PST)
Message-ID: <52F4D9AE.7040401@redhat.com>
Date: Fri, 07 Feb 2014 08:03:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/9] mm: Mark functions as static in memory.c
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <2bd9a806eae6958a75de452ba1d09f5cb6e2f7bc.1391167128.git.rashika.kheria@gmail.com>
In-Reply-To: <2bd9a806eae6958a75de452ba1d09f5cb6e2f7bc.1391167128.git.rashika.kheria@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, josh@joshtriplett.org

On 02/07/2014 07:03 AM, Rashika Kheria wrote:
> Mark functions as static in memory.c because they are not used outside
> this file.
> 
> This eliminates the following warnings in mm/memory.c:
> mm/memory.c:3530:5: warning: no previous prototype for a??numa_migrate_prepa?? [-Wmissing-prototypes]
> mm/memory.c:3545:5: warning: no previous prototype for a??do_numa_pagea?? [-Wmissing-prototypes]
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
