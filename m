Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8274F6B02F7
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 17:13:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x78so17194455pff.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 14:13:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r59sor2772836plb.137.2017.09.11.14.13.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 14:13:38 -0700 (PDT)
Date: Mon, 11 Sep 2017 14:13:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, compaction: kcompactd should not ignore pageblock
 skip
In-Reply-To: <c4a19acf-20f7-095a-1234-926b8d98c174@suse.cz>
Message-ID: <alpine.DEB.2.10.1709111411520.108216@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com> <5d578461-0982-f719-3a04-b2f3552dc7cc@suse.cz> <alpine.DEB.2.10.1709101801200.85650@chino.kir.corp.google.com> <c4a19acf-20f7-095a-1234-926b8d98c174@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 11 Sep 2017, Vlastimil Babka wrote:

> > A follow-up change will set the pageblock skip for this memory since it is 
> > never useful for either scanner.
> > """
> > 
> >> Also there's now a danger that in cases where there's no direct
> >> compaction happening (just kcompactd), nothing will ever call
> >> __reset_isolation_suitable().
> >>
> > 
> > I'm not sure that is helpful in a context where no high-order memory can 
> > call direct compaction that kcompactd needlessly scanning the same memory 
> > over and over is beneficial.
> 
> The point is that if it becomes beneficial again, we won't know as there
> will be still be skip bits.
> 

Why is kcompactd_do_work() not sometimes doing 
__reset_isolation_suitable() in the first place, if only to reset the 
per-zone migration and freeing scanner cached pfns?  It seems fragile to 
rely on other threads doing direct compaction to reset the per-zone state 
of compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
