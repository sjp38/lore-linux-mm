Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12A9F6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:39:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so9730096wme.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:39:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si24417795wmm.87.2016.04.26.04.39.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:39:56 -0700 (PDT)
Subject: Re: [PATCH 11/28] mm, page_alloc: Remove unnecessary initialisation
 in get_page_from_freelist
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-12-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F538A.8020602@suse.cz>
Date: Tue, 26 Apr 2016 13:39:54 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-12-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:59 AM, Mel Gorman wrote:
> See subject.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
