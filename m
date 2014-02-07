Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0E96B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:47:19 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so3747678pbc.4
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:47:19 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id x3si6328362pbf.151.2014.02.07.12.47.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:47:17 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id p10so3621100pdj.29
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:47:17 -0800 (PST)
Date: Fri, 7 Feb 2014 12:47:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/9] mm: Mark functions as static in memory.c
In-Reply-To: <2bd9a806eae6958a75de452ba1d09f5cb6e2f7bc.1391167128.git.rashika.kheria@gmail.com>
Message-ID: <alpine.DEB.2.02.1402071246351.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com> <2bd9a806eae6958a75de452ba1d09f5cb6e2f7bc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1120541338-1391806036=:4212"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, josh@joshtriplett.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1120541338-1391806036=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark functions as static in memory.c because they are not used outside
> this file.
> 
> This eliminates the following warnings in mm/memory.c:
> mm/memory.c:3530:5: warning: no previous prototype for a??numa_migrate_prepa?? [-Wmissing-prototypes]
> mm/memory.c:3545:5: warning: no previous prototype for a??do_numa_pagea?? [-Wmissing-prototypes]
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-1120541338-1391806036=:4212--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
