Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5599B6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 21:45:28 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id ij19so2967591vcb.37
        for <linux-mm@kvack.org>; Fri, 30 May 2014 18:45:28 -0700 (PDT)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id jv10si4522404veb.79.2014.05.30.18.45.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 18:45:27 -0700 (PDT)
Received: by mail-ve0-f174.google.com with SMTP id jw12so3026549veb.33
        for <linux-mm@kvack.org>; Fri, 30 May 2014 18:45:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzzHS9YSzZpxMoF1vwoBh+NxLE26Tr2OC38=PsB8Mjwig@mail.gmail.com>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
	<20140529015830.GG6677@dastard>
	<20140529233638.GJ10092@bbox>
	<20140530001558.GB14410@dastard>
	<20140530021247.GR10092@bbox>
	<CA+55aFzzHS9YSzZpxMoF1vwoBh+NxLE26Tr2OC38=PsB8Mjwig@mail.gmail.com>
Date: Fri, 30 May 2014 18:45:27 -0700
Message-ID: <CA+55aFxqJXZfGaspc0bNPQa_7x5kmGuHrQG8dRzta4YpLYqiBQ@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 9:37 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> It really might be very good to create a "struct alloc_info" that
> contains those shared arguments, and just pass a (const) pointer to
> that around. [ .. ]
>
> Ugh. I think I'll try looking at that tomorrow.

I did look at it, but the thing is horrible. I started on this
something like ten times, and always ended up running away screaming.
Some things are truly fixed (notably "order"), but most things end up
changing subtly halfway through the callchain.

I might look at it some more later, but people may have noticed that I
decided to just apply Minchan's original patch in the meantime. I'll
make an rc8 this weekend..

        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
