Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 11D216B04E9
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 14:16:20 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r200so373809oie.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:16:20 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id r205si3862730oia.315.2017.08.24.11.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 11:16:17 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id k77so2275248oib.2
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 11:16:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <85fb2a78-cbb7-dceb-12e8-7d18519c30a0@linux.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
 <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com> <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
 <CA+55aFzxisTJS+Z7q+Dp9oRgvMpXEQRedYFu7-k_YXEE-=htgA@mail.gmail.com> <85fb2a78-cbb7-dceb-12e8-7d18519c30a0@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Aug 2017 11:16:15 -0700
Message-ID: <CA+55aFwOxWWgL3Xdh_m3pbeoYedqBkpvLiJNcEYWUvOAzmB3zQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 24, 2017 at 10:49 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
>
> These changes look fine.  We are testing them now.
> Does the second patch in the series look okay to you?

I didn't really have any reaction to that one, as long as Mel&co are
ok with it, I'm fine with it.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
