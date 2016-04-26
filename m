Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFD4D6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:41:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so10129729wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:41:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c5si29514985wjm.164.2016.04.26.04.41.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:41:25 -0700 (PDT)
Subject: Re: [PATCH 12/28] mm, page_alloc: Remove unnecessary initialisation
 from __alloc_pages_nodemask()
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <20160416072152.GH32073@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F53E4.90207@suse.cz>
Date: Tue, 26 Apr 2016 13:41:24 +0200
MIME-Version: 1.0
In-Reply-To: <20160416072152.GH32073@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/16/2016 09:21 AM, Mel Gorman wrote:
> page is guaranteed to be set before it is read with or without the
> initialisation.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
