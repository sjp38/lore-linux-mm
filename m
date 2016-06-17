Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E951D6B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:35:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 4so38486876wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:35:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si7197505wji.192.2016.06.17.01.35.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 01:35:17 -0700 (PDT)
Subject: Re: [PATCH 18/27] mm: Move most file-based accounting to the node
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-19-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <65a05913-77ac-528f-b85f-6ac26bf9efda@suse.cz>
Date: Fri, 17 Jun 2016 10:35:12 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-19-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> There are now a number of accounting oddities such as mapped file pages
> being accounted for on the node while the total number of file pages are
> accounted on the zone. This can be coped with to some extent but it's
> confusing so this patch moves the relevant file-based accounted.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
