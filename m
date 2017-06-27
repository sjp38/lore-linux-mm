Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B45C6B0292
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 13:04:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 21so5385857wmt.15
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:04:13 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 140si3185783wmp.127.2017.06.27.10.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 10:04:11 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id 131so6943031wmq.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:04:11 -0700 (PDT)
Date: Tue, 27 Jun 2017 20:04:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: linux-next: BUG: Bad page state in process ip6tables-save
 pfn:1499f4
Message-ID: <20170627170408.4eowigh3pho2ph36@node.shutemov.name>
References: <CANaxB-zPGB8Yy9480pTFmj9HECGs3quq9Ak18aBUbx9TsNSsaw@mail.gmail.com>
 <20170624001738.GB7946@gmail.com>
 <20170624150824.GA19708@gmail.com>
 <bff14c53-815a-0874-5ed9-43d3f4c54ffd@suse.cz>
 <20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com>
 <87lgodl6c8.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lgodl6c8.fsf@e105922-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Steve Capper <steve.capper@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrei Vagin <avagin@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Cyrill Gorcunov <gorcunov@openvz.org>

On Tue, Jun 27, 2017 at 05:53:59PM +0100, Punit Agrawal wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > On Tue, Jun 27, 2017 at 09:18:15AM +0200, Vlastimil Babka wrote:
> >> On 06/24/2017 05:08 PM, Andrei Vagin wrote:
> >> > On Fri, Jun 23, 2017 at 05:17:44PM -0700, Andrei Vagin wrote:
> >> >> On Thu, Jun 22, 2017 at 11:21:03PM -0700, Andrei Vagin wrote:
> >> >>> Hello,
> >> >>>
> >> >>> We run CRIU tests for linux-next and today they triggered a kernel
> >> >>> bug. I want to mention that this kernel is built with kasan. This bug
> >> >>> was triggered in travis-ci. I can't reproduce it on my host. Without
> >> >>> kasan, kernel crashed but it is impossible to get a kernel log for
> >> >>> this case.
> >> >>
> >> >> We use this tree
> >> >> https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/
> >> >>
> >> >> This issue isn't reproduced on the akpm-base branch and
> >> >> it is reproduced each time on the akpm branch. I didn't
> >> >> have time today to bisect it, will do on Monday.
> >> > 
> >> > c3aab7b2d4e8434d53bc81770442c14ccf0794a8 is the first bad commit
> >> > 
> >> > commit c3aab7b2d4e8434d53bc81770442c14ccf0794a8
> >> > Merge: 849c34f 93a7379
> >> > Author: Stephen Rothwell
> >> > Date:   Fri Jun 23 16:40:07 2017 +1000
> >> > 
> >> >     Merge branch 'akpm-current/current'
> >> 
> >> Hm is it really the merge of mmotm itself and not one of the patches in
> >> mmotm?
> >> Anyway smells like THP, adding Kirill.
> >
> > Okay, it took a while to figure it out.
> 
> I'm sorry you had to go chasing for this one again.
> 
> I'd found the same issue while investigating an ltp failure on arm64[0] and
> sent a fix[1]. The fix is effectively the same as your patch below.
> 
> Andrew picked up the patch from v5 posting and I can see it in today's
> next[2].
> 
> 
> [0] http://lists.infradead.org/pipermail/linux-arm-kernel/2017-June/510318.html
> [1] https://patchwork.kernel.org/patch/9766193/
> [2] https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/mm/gup.c?h=next-20170627&id=d31945b5d4ab4490fb5f961dd5b066cc9f560eb3

Ah. Okay, no problem then.

But I think my fix is neater :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
