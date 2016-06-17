Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id ECBEA6B025F
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:28:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so6083007wmr.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:28:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q184si9396783wme.57.2016.06.17.01.28.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 01:28:52 -0700 (PDT)
Subject: Re: [PATCH 17/27] mm: Rename NR_ANON_PAGES to NR_ANON_MAPPED
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-18-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <46c75f05-7a07-9f9d-3bf5-461971e2ecc4@suse.cz>
Date: Fri, 17 Jun 2016 10:28:50 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-18-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> NR_FILE_PAGES  is the number of        file pages.
> NR_FILE_MAPPED is the number of mapped file pages.
> NR_ANON_PAGES  is the number of mapped anon pages.
>
> This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and NR_ANON_PAGES for
> mapped pages. This patch renames NR_ANON_PAGES so we have
>
> NR_FILE_PAGES  is the number of        file pages.
> NR_FILE_MAPPED is the number of mapped file pages.
> NR_ANON_MAPPED is the number of mapped anon pages.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
