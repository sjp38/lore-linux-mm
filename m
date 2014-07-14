Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id D793F6B0036
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 09:21:07 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so3995908wgh.3
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 06:21:04 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l4si10800584wif.86.2014.07.14.06.21.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 06:21:01 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/3] mm: vmscan: followup fixes to cleanups in -mm
Date: Mon, 14 Jul 2014 09:20:46 -0400
Message-Id: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

here is a follow-up to feedback on patches you already have in -mm.
This series is not linear: the first two patches are fixlets according
to their name, the third one could be placed after "mm: vmscan: move
swappiness out of scan_control".

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
