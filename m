Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B68A440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:44:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l124so562270wmg.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:44:52 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id i21si2185640wmc.264.2017.08.24.13.44.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 13:44:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 7F7B2F41C0
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:44:49 +0000 (UTC)
Date: Thu, 24 Aug 2017 21:44:48 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170824204448.if2mve3iy5k425di@techsingularity.net>
References: <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A377@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwavpFfKNW9NVgNhLggqhii-guc5aX1X5fxrPK+==id0g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A8AB@SHSMSX103.ccr.corp.intel.com>
 <6e8b81de-e985-9222-29c5-594c6849c351@linux.intel.com>
 <CA+55aFzbom=qFc2pYk07XhiMBn083EXugSUHmSVbTuu8eJtHVQ@mail.gmail.com>
 <CA+55aFzxisTJS+Z7q+Dp9oRgvMpXEQRedYFu7-k_YXEE-=htgA@mail.gmail.com>
 <85fb2a78-cbb7-dceb-12e8-7d18519c30a0@linux.intel.com>
 <CA+55aFwOxWWgL3Xdh_m3pbeoYedqBkpvLiJNcEYWUvOAzmB3zQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwOxWWgL3Xdh_m3pbeoYedqBkpvLiJNcEYWUvOAzmB3zQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 24, 2017 at 11:16:15AM -0700, Linus Torvalds wrote:
> On Thu, Aug 24, 2017 at 10:49 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
> >
> > These changes look fine.  We are testing them now.
> > Does the second patch in the series look okay to you?
> 
> I didn't really have any reaction to that one, as long as Mel&co are
> ok with it, I'm fine with it.
> 

I've no strong objections or concerns. I'm disappointed that the
original root cause for this could not be found but hope that eventually a
reproducible test case will eventually be available. Despite having access
to a 4-socket box, I was still unable to create a workload that caused
large delays on wakeup. I'm going to have to stop as I don't think it's
possible to create on that particular machine for whatever reason.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
