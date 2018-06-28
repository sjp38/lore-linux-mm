Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5D16B000D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 01:35:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w23-v6so1917371pgv.1
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:35:19 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u17-v6si4950919pgv.455.2018.06.27.22.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 22:35:18 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 00/21] mm, THP, swap: Swapout/swapin THP in one piece
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
	<87r2krfpi2.fsf@yhuang-dev.intel.com>
	<20180627223118.dd2f52d87f53e7e002ed0153@linux-foundation.org>
Date: Thu, 28 Jun 2018 13:35:15 +0800
In-Reply-To: <20180627223118.dd2f52d87f53e7e002ed0153@linux-foundation.org>
	(Andrew Morton's message of "Wed, 27 Jun 2018 22:31:18 -0700")
Message-ID: <87muvffp7w.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 28 Jun 2018 13:29:09 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
>
>> Andrew Morton <akpm@linux-foundation.org> writes:
>> 
>> > On Fri, 22 Jun 2018 11:51:30 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>> >
>> >> This is the final step of THP (Transparent Huge Page) swap
>> >> optimization.  After the first and second step, the splitting huge
>> >> page is delayed from almost the first step of swapout to after swapout
>> >> has been finished.  In this step, we avoid splitting THP for swapout
>> >> and swapout/swapin the THP in one piece.
>> >
>> > It's a tremendously good performance improvement.  It's also a
>> > tremendously large patchset :(
>> >
>> > And it depends upon your
>> > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch and
>> > mm-fix-race-between-swapoff-and-mincore.patch, the first of which has
>> > been floating about since February without adequate review.
>> >
>> > I'll give this patchset a spin in -mm to see what happens and will come
>> > back later to take a closer look.  But the best I can do at this time
>> > is to hopefully cc some possible reviewers :)
>> 
>> Thanks a lot for your help!  Hope more people can review it!
>
> I took it out of -mm again, temporarily.  Due to a huge tangle with the
> xarray conversions in linux-next.

No problem.  I will rebase the patchset on your latest -mm tree, or the
next version to be released?

Best Regards,
Huang, Ying
