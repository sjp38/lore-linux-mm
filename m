Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 392B96B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 14:43:26 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y84so19017438lfc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 11:43:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si4685721wme.105.2016.04.26.11.43.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 11:43:25 -0700 (PDT)
Subject: Re: [PATCH 24/28] mm, page_alloc: Remove unnecessary variable from
 free_pcppages_bulk
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-12-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571FB6CC.4060505@suse.cz>
Date: Tue, 26 Apr 2016 20:43:24 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-12-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> The original count is never reused so it can be removed.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
