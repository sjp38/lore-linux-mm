Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1C1556B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 01:52:50 -0400 (EDT)
Date: Tue, 23 Jul 2013 01:52:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: kill one if in loop of __free_pages_bootmem
Message-ID: <20130723055241.GI715@cmpxchg.org>
References: <1374545862-17741-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374545862-17741-1-git-send-email-yinghai@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 22, 2013 at 07:17:42PM -0700, Yinghai Lu wrote:
> We should not check loop+1 with loop end in loop body.
> Just duplicate two lines code to avoid it.
> 
> That will help a bit when we have huge amount of pages on
> system with 16TiB memory.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>

Disassembly looks good, thanks!

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
