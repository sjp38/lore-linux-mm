Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2387D6B0253
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:38:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so10051339wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:38:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i13si24466931wmc.78.2016.04.26.04.38.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:38:15 -0700 (PDT)
Subject: Re: [PATCH 10/28] mm, page_alloc: Remove unnecessary local variable
 in get_page_from_freelist
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-11-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F5326.5000907@suse.cz>
Date: Tue, 26 Apr 2016 13:38:14 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-11-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:59 AM, Mel Gorman wrote:
> zonelist here is a copy of a struct field that is used once. Ditch it.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
