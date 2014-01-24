Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 490826B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 06:18:26 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id l18so2761612wgh.11
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 03:18:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb8si1192068wib.78.2014.01.24.03.18.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 03:18:25 -0800 (PST)
Date: Fri, 24 Jan 2014 11:18:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, compaction: ignore pageblock skip when manually
 invoking compaction
Message-ID: <20140124111822.GS4963@suse.de>
References: <alpine.DEB.2.02.1401222154220.7503@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401222154220.7503@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 22, 2014 at 09:56:31PM -0800, David Rientjes wrote:
> The cached pageblock hint should be ignored when triggering compaction
> through /proc/sys/vm/compact_memory so all eligible memory is isolated.  
> Manually invoking compaction is known to be expensive, there's no need to
> skip pageblocks based on heuristics (mainly for debugging).
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
