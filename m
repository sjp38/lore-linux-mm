Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0190A830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:14:07 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id e127so42100004pfe.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 18:14:06 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id ey9si13022460pab.123.2016.02.18.18.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 18:14:06 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id x65so42099494pfb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 18:14:06 -0800 (PST)
Date: Fri, 19 Feb 2016 11:15:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160219021522.GA11625@swordfish>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20160218092926.083ca007@gandalf.local.home>
 <20160219003421.GA587@swordfish>
 <CAAmzW4Ni2uZ_J1dcfHPNPYDc0EDDDOL+_oKD-+OZ=Cmg=8sgGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4Ni2uZ_J1dcfHPNPYDc0EDDDOL+_oKD-+OZ=Cmg=8sgGA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On (02/19/16 10:39), Joonsoo Kim wrote:
[..]
> > not sure if it's worth mentioning in the comment, but the other
> > concern here is the performance impact of an extra function call,
> > I believe. otherwise, Joonsoo would just do:
> 
> It's very natural thing so I'm not sure it is worth mentioning.

agree.

> > and in mm/debug_page_ref.c
> >
> > void __page_ref_set(struct page *page, int v)
> > {
> >         if (trace_page_ref_set_enabled())
> >                 trace_page_ref_set(page, v);
> > }
> > EXPORT_SYMBOL(__page_ref_set);
> > EXPORT_TRACEPOINT_SYMBOL(page_ref_set);
> 
> It is what I did in v1.

ah... indeed. well, "That was a year ago, how am I suppose to remember"

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
