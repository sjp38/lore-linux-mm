Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE3B6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:43:51 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so3594637pdj.22
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:43:50 -0800 (PST)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id tq5si6323014pac.124.2014.02.07.12.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:43:49 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id um1so3699466pbc.5
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:43:49 -0800 (PST)
Date: Fri, 7 Feb 2014 12:43:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/9] mm: Mark function as static in compaction.c
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Message-ID: <alpine.DEB.2.02.1402071243380.4212@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1626153487-1391805828=:4212"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, josh@joshtriplett.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1626153487-1391805828=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark function as static in compaction.c because it is not used outside
> this file.
> 
> This eliminates the following warning from mm/compaction.c:
> mm/compaction.c:1190:9: warning: no previous prototype for a??sysfs_compact_nodea?? [-Wmissing-prototypes
> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-1626153487-1391805828=:4212--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
