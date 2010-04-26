Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F14D6B01FE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 07:59:03 -0400 (EDT)
Received: by bwz23 with SMTP id 23so11555565bwz.6
        for <linux-mm@kvack.org>; Mon, 26 Apr 2010 04:59:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BD57213.7060207@linux.vnet.ibm.com>
References: <20100322235053.GD9590@csn.ul.ie>
	 <20100419214412.GB5336@cmpxchg.org>
	 <4BCD55DA.2020000@linux.vnet.ibm.com>
	 <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com>
	 <4BCE7DD1.70900@linux.vnet.ibm.com>
	 <4BCEAAC6.7070602@linux.vnet.ibm.com> <4BCEFB4C.1070206@redhat.com>
	 <4BCFEAD0.4010708@linux.vnet.ibm.com>
	 <4BD57213.7060207@linux.vnet.ibm.com>
Date: Mon, 26 Apr 2010 20:59:30 +0900
Message-ID: <p2y2f11576a1004260459jcaf79962p50e4d29f990019ee@mail.gmail.com>
Subject: Re: Subject: [PATCH][RFC] mm: make working set portion that is
	protected tunable v2
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, gregkh@novell.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi

I've quick reviewed your patch. but unfortunately I can't write my
reviewed-by sign.

> Subject: [PATCH][RFC] mm: make working set portion that is protected tunable v2
> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
>
> *updates in v2*
> - use do_div
>
> This patch creates a knob to help users that have workloads suffering from the
> fix 1:1 active inactive ratio brought into the kernel by "56e49d21 vmscan:
> evict use-once pages first".
> It also provides the tuning mechanisms for other users that want an even bigger
> working set to be protected.

We certainly need no knob. because typical desktop users use various
application,
various workload. then, the knob doesn't help them.

Probably, I've missed previous discussion. I'm going to find your previous mail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
