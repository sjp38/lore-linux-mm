Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27261828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 21:54:42 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id cx13so215189172pac.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 18:54:42 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n128si1102361pfn.256.2016.07.05.18.54.40
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 18:54:41 -0700 (PDT)
Date: Wed, 6 Jul 2016 10:55:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when
 terminating freeing scanner
Message-ID: <20160706015511.GA13566@bbox>
References: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
 <7ecb4f2d-724f-463f-961f-efba1bdb63d2@suse.cz>
 <alpine.DEB.2.10.1607051357050.110721@chino.kir.corp.google.com>
 <20160706014109.GC23627@js1304-P5Q-DELUXE>
MIME-Version: 1.0
In-Reply-To: <20160706014109.GC23627@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, stable@vger.kernel.org

On Wed, Jul 06, 2016 at 10:41:09AM +0900, Joonsoo Kim wrote:

< snip >
> > Do you have any objection to this fix for 4.7?
> > 
> > Joonson and/or Minchan, does this address the issue that you reported?
> 
> Unfortunately, I have no test case to trigger it. But, I think that
> this patch will address it. Anyway, I commented one problem on this

I just queued this patch into my testing machine which triggered the
problem so let's wait. It triggered in 6 hours most of time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
