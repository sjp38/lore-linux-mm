Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C671582F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 12:24:03 -0500 (EST)
Received: by wimw2 with SMTP id w2so14857022wim.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 09:24:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pe3si9263699wjb.62.2015.11.05.09.24.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 09:24:02 -0800 (PST)
Subject: Re: mm Documentation: a little tidying in proc.txt
References: <alpine.LSU.2.11.1510291205481.3475@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563B90B0.9020202@suse.cz>
Date: Thu, 5 Nov 2015 18:24:00 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510291205481.3475@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 10/29/2015 08:07 PM, Hugh Dickins wrote:
> There's an odd line about "Locked" at the head of the description of
> /proc/meminfo: it seems to have strayed from /proc/PID/smaps, so lead
> it back there.  Move "Swap" and "SwapPss" descriptions down above it,
> to match the order in the file (though "PageSize"s still undescribed).
> 
> The example of "Locked: 374 kB" (the same as Pss, neither Rss nor Size)
> is so unlikely as to be misleading: just make it 0, this is /bin/bash
> text; which would be "dw" (disabled write) not "de" (do not expand).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
