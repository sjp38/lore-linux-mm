Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A36236B003A
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 04:38:11 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so918456pab.29
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 01:38:11 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ot3si6957537pdb.222.2014.07.16.01.38.09
        for <linux-mm@kvack.org>;
        Wed, 16 Jul 2014 01:38:10 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:44:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 00/10] fix freepage count problems due to memory isolation
Message-ID: <20140716084402.GB20359@js1304-P5Q-DELUXE>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
 <53B6C947.1070603@suse.cz>
 <20140707044932.GA29236@js1304-P5Q-DELUXE>
 <53BAAFA5.9070403@suse.cz>
 <20140714062222.GA11317@js1304-P5Q-DELUXE>
 <53C3A7A5.9060005@suse.cz>
 <20140715082828.GM11317@js1304-P5Q-DELUXE>
 <53C4E813.7020108@suse.cz>
 <CAAmzW4PgQSt3xXti9Y5oy9eNqKz8Gq3fv8rB=A0Gt7NtUSZ35w@mail.gmail.com>
 <20140715100013.GX9918@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715100013.GX9918@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Lisa Du <cldu@marvell.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 15, 2014 at 12:00:13PM +0200, Peter Zijlstra wrote:
> On Tue, Jul 15, 2014 at 06:39:20PM +0900, Joonsoo Kim wrote:
> > >>>>>>>>
> 
> tl;dr, if you want me to read your emails, trim them.

Okay. I will do it. Sorry for bothering you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
