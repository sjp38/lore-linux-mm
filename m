Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 101C36B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 21:10:17 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id z135so74655640iof.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:10:17 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z8si1184561igg.2.2016.02.24.18.10.15
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 18:10:16 -0800 (PST)
Date: Thu, 25 Feb 2016 11:11:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 1/2] mm: introduce page reference manipulation
 functions
Message-ID: <20160225021134.GA14784@js1304-P5Q-DELUXE>
References: <1456212078-22732-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160223153244.83a5c3ca430c4248a4a34cc0@linux-foundation.org>
 <20160225003454.GB9723@js1304-P5Q-DELUXE>
 <20160224175333.8957903d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160224175333.8957903d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Wed, Feb 24, 2016 at 05:53:33PM -0800, Andrew Morton wrote:
> On Thu, 25 Feb 2016 09:34:55 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > > 
> > > The patches will be a bit of a pain to maintain but surprisingly they
> > > apply OK at present.  It's possible that by the time they hit upstream,
> > > some direct ->_count references will still be present and it will
> > > require a second pass to complete the conversion.
> > 
> > In fact, the patch doesn't change direct ->_count reference for
> > *read*. That's the reason that it is surprisingly OK at present.
> > 
> > It's a good idea to change direct ->_count reference even for read.
> > How about changing it in rc2 after mering this patch in rc1?
> 
> Sounds fair enough.
> 
> Although I'm counting only 11 such sites so perhaps we just go ahead
> and do it?

Okay. It's less than I thought. I will do it soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
