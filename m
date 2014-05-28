Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id C6E176B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 12:13:51 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id db11so12759891veb.15
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:13:51 -0700 (PDT)
Received: from mail-vc0-x233.google.com (mail-vc0-x233.google.com [2607:f8b0:400c:c03::233])
        by mx.google.com with ESMTPS id dk3si10984634vcb.8.2014.05.28.09.13.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 09:13:51 -0700 (PDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so12723682vcb.10
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:13:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140528120817.71921d6a@gandalf.local.home>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CAFLxGvyV2Upn7+uTtScu2_LGazy9L+HU9DWEC==0qyZphCrauA@mail.gmail.com>
	<20140528120817.71921d6a@gandalf.local.home>
Date: Wed, 28 May 2014 09:13:51 -0700
Message-ID: <CA+55aFwK5PnWonJZUA0O0dZp=k6RL7gRE5rjSTpxwcbS8ydkyQ@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>

On Wed, May 28, 2014 at 9:08 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> What performance impact are you looking for? Now if the system is short
> on memory, it would probably cause issues in creating tasks.

It doesn't necessarily need to be short on memory, it could just be
fragmented. But a page order of 2 should still be ok'ish.

That said, this is definitely not a rc7 issue. I'd *much* rather
disable swap from direct reclaim, although that kind of patch too
would be a "can Minchan test it, we can put it in the next merge
window and then backport it if we don't have issues".

I see that Johannes already did a patch for that (and this really
_has_ come up before), although I'd skip the WARN_ON_ONCE() part
except for perhaps Minchan testing it.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
