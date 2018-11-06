Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 797096B029B
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 19:32:54 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id n22-v6so11143724pff.2
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 16:32:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q204sor12410469pgq.70.2018.11.05.16.32.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 16:32:53 -0800 (PST)
Message-ID: <1541464370.196084.166.camel@acm.org>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 05 Nov 2018 16:32:50 -0800
In-Reply-To: <CAKgT0Ue59US_f-cZtoA=yVbFJ03ca5OMce2opUdQcsvgd8LWMw@mail.gmail.com>
References: <20181105204000.129023-1-bvanassche@acm.org>
	 <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
	 <1541454489.196084.157.camel@acm.org>
	 <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
	 <1541457654.196084.159.camel@acm.org>
	 <CAKgT0Udci4Ai4OD20NSRuDckE_G4RHma3Bg6H1Um6N9Se_zPew@mail.gmail.com>
	 <1541462466.196084.163.camel@acm.org>
	 <CAKgT0Ue59US_f-cZtoA=yVbFJ03ca5OMce2opUdQcsvgd8LWMw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux@rasmusvillemoes.dk, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, guro@fb.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Mon, 2018-11-05 at 16:11 -0800, Alexander Duyck wrote:
+AD4 If we really don't care then why even bother with the switch statement
+AD4 anyway? It seems like you could just do one ternary operator and be
+AD4 done with it. Basically all you need is:
+AD4 return (defined(CONFIG+AF8-ZONE+AF8-DMA) +ACYAJg (flags +ACY +AF8AXw-GFP+AF8-DMA)) ? KMALLOC+AF8-DMA :
+AD4         (flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE) ? KMALLOC+AF8-RECLAIM : 0+ADs
+AD4 
+AD4 Why bother with all the extra complexity of the switch statement?

I don't think that defined() can be used in a C expression. Hence the
IS+AF8-ENABLED() macro. If you fix that, leave out four superfluous parentheses,
test your patch, post that patch and cc me then I will add my Reviewed-by.

Bart.
