Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8ACD36B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 01:32:37 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so2145289pdi.37
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 22:32:37 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id v6si5215252pdr.119.2014.12.09.22.32.34
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 22:32:36 -0800 (PST)
Date: Wed, 10 Dec 2014 15:36:28 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/4] enhance compaction success rate
Message-ID: <20141210063628.GB13371@js1304-P5Q-DELUXE>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <54856C72.4040705@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54856C72.4040705@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 08, 2014 at 10:16:34AM +0100, Vlastimil Babka wrote:
> On 12/08/2014 08:16 AM, Joonsoo Kim wrote:
> >This patchset aims at increase of compaction success rate. Changes are
> >related to compaction finish condition and freepage isolation condition.
> >
> > From these changes, I did stress highalloc test in mmtests with nonmovable
> >order 7 allocation configuration, and success rate (%) at phase 1 are,
> >
> >Base	Patch-1	Patch-3	Patch-4
> >55.00	57.00	62.67	64.00
> >
> >And, compaction success rate (%) on same test are,
> >
> >Base	Patch-1	Patch-3	Patch-4
> >18.47	28.94	35.13	41.50
> 
> Did you test Patch-2 separately? Any difference to Patch 1?

I didn't test it separately. I guess that there is no remarkable
difference because it just slightly changes page stealing logic, not
compaction logic. Compaction success rate would not be affected by
patch 2, but, I will check it next time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
