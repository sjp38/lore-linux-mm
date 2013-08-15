Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 0FCE86B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 06:47:31 -0400 (EDT)
Date: Thu, 15 Aug 2013 11:47:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd skips compaction if reclaim order drops to zero?
Message-ID: <20130815104727.GT2296@suse.de>
References: <CAJd=RBBF2h_tRpbTV6OkxQOfkvKt=ebn_PbE8+r7JxAuaFZxFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBBF2h_tRpbTV6OkxQOfkvKt=ebn_PbE8+r7JxAuaFZxFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Aug 15, 2013 at 06:02:53PM +0800, Hillf Danton wrote:
> If the allocation order is not high, direct compaction does nothing.
> Can we skip compaction here if order drops to zero?
> 

If the allocation order is not high then

pgdat_needs_compaction == (order > 0) == false == no calling compact_pdatt

In the case where order is reset to 0 due to fragmentation then it does
call compact_pgdat but it does no work due to the cc->order check in
__compact_pgdat.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
