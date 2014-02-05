Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4B74E6B003C
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:06:44 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so8824569pdj.26
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:06:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ay1si19408052pbd.216.2014.02.04.16.06.43
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 16:06:43 -0800 (PST)
Date: Tue, 4 Feb 2014 16:06:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, page_alloc: make first_page visible before PageTail
Message-Id: <20140204160641.8f5d369eeb2d0318618d6d5f@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1402041557380.10140@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1401312037340.6630@diagnostix.dwd.de>
	<20140203122052.GC2495@dhcp22.suse.cz>
	<alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de>
	<20140203162036.GJ2495@dhcp22.suse.cz>
	<52EFC93D.3030106@suse.cz>
	<alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com>
	<alpine.LRH.2.02.1402040713220.13901@diagnostix.dwd.de>
	<alpine.DEB.2.02.1402041557380.10140@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Holger Kiehl <Holger.Kiehl@dwd.de>, Christoph Lameter <cl@linux.com>, Rafael Aquini <aquini@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 4 Feb 2014 16:02:39 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> Commit bf6bddf1924e ("mm: introduce compaction and migration for ballooned 
> pages") introduces page_count(page) into memory compaction which 
> dereferences page->first_page if PageTail(page).
> 
> Introduce a store memory barrier to ensure page->first_page is properly 
> initialized so that code that does page_count(page) on pages off the lru 
> always have a valid p->first_page.

Could we have a code comment please?  Even checkpatch knows this rule!

> Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>

What did Holger report?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
