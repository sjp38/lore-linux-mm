Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4016B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:37:31 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so9887702lfq.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:37:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e10si29497770wjr.193.2016.04.26.04.37.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:37:29 -0700 (PDT)
Subject: Re: [PATCH 09/28] mm, page_alloc: Convert nr_fair_skipped to bool
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-10-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F52F7.2000203@suse.cz>
Date: Tue, 26 Apr 2016 13:37:27 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-10-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:59 AM, Mel Gorman wrote:
> The number of zones skipped to a zone expiring its fair zone allocation quota
> is irrelevant. Convert to bool.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
