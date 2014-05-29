Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 37A976B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 01:17:25 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id m15so12270215wgh.20
        for <linux-mm@kvack.org>; Wed, 28 May 2014 22:17:24 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id eq8si8947088wib.30.2014.05.28.22.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 May 2014 22:17:23 -0700 (PDT)
Message-ID: <5386C234.1070301@zytor.com>
Date: Wed, 28 May 2014 22:14:28 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>	<1401260039-18189-2-git-send-email-minchan@kernel.org>	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>	<20140528223142.GO8554@dastard>	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>	<20140529013007.GF6677@dastard> <CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
In-Reply-To: <CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On 05/28/2014 07:42 PM, Linus Torvalds wrote:
> 
> And Minchan running out of stack is at least _partly_ due to his debug
> options (that DEBUG_PAGEALLOC thing as an extreme example, but I
> suspect there's a few other options there that generate more bloated
> data structures too too).
> 

I have wondered if a larger stack would make sense as a debug option.
I'm just worried it will be abused.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
