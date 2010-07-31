Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AF3A06B02B7
	for <linux-mm@kvack.org>; Sat, 31 Jul 2010 14:09:36 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2918415iwn.14
        for <linux-mm@kvack.org>; Sat, 31 Jul 2010 11:09:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100731175951.GA17519@infradead.org>
References: <20100728071705.GA22964@localhost>
	<20100731161358.GA5147@localhost>
	<20100731173328.GA21072@infradead.org>
	<AANLkTi=+muw_2jWq1QKsxp6A_fAtdhdns7MD_bKQo-72@mail.gmail.com>
	<20100731175951.GA17519@infradead.org>
Date: Sat, 31 Jul 2010 21:09:35 +0300
Message-ID: <AANLkTikG7UOSh=iH02YwO0ihpu2waKt3bHH7LLK-33MP@mail.gmail.com>
Subject: Re: [PATCH] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 31, 2010 at 8:59 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Sat, Jul 31, 2010 at 08:55:57PM +0300, Pekka Enberg wrote:
>> Do you have CONFIG_SLUB enabled? It does high order allocations by
>> default for performance reasons.
>
> Yes. This is a kernel using slub.

You can pass "slub_debug=o" as a kernel parameter to disable higher
order allocations if you want to test things. The per-cache default
order is calculated in calculate_order() of mm/slub.c. How many CPUs
do you have on your system?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
