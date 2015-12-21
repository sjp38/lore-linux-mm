Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B408F6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 07:47:27 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l126so67800315wml.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 04:47:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jt3si29241900wjb.150.2015.12.21.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 04:47:26 -0800 (PST)
Subject: Re: [PATCH] mm: page_alloc: Remove unnecessary parameter from
 __rmqueue
References: <20151202150858.GD2015@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5677F4DC.6040003@suse.cz>
Date: Mon, 21 Dec 2015 13:47:24 +0100
MIME-Version: 1.0
In-Reply-To: <20151202150858.GD2015@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 12/02/2015 04:08 PM, Mel Gorman wrote:
> Commit 0aaa29a56e4f ("mm, page_alloc: reserve pageblocks for high-order
> atomic allocations on demand") added an unnecessary and unused parameter
> to __rmqueue. It was a parameter that was used in an earlier version of
> the patch and then left behind. This patch cleans it up.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
