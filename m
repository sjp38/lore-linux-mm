Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id E11976B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:08:10 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id 2so4650828qeb.2
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 14:08:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k3si9087513qao.90.2013.11.25.14.08.09
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 14:08:09 -0800 (PST)
Message-ID: <5293CA44.10904@redhat.com>
Date: Mon, 25 Nov 2013 17:08:04 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm: compaction: encapsulate defer reset logic
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz> <1385389570-11393-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1385389570-11393-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On 11/25/2013 09:26 AM, Vlastimil Babka wrote:
> Currently there are several functions to manipulate the deferred compaction
> state variables. The remaining case where the variables are touched directly
> is when a successful allocation occurs in direct compaction, or is expected
> to be successful in the future by kswapd. Here, the lowest order that is
> expected to fail is updated, and in the case of direct compaction, the deferred
> status is reset completely.
>
> Create a new function compaction_defer_reset() to encapsulate this
> functionality and make it easier to understand the code. No functional change.
>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
