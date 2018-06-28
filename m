Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB936B0003
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 01:29:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n19-v6so2156967pff.8
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:29:18 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 67-v6si5762044pfe.49.2018.06.27.22.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 22:29:17 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 00/21] mm, THP, swap: Swapout/swapin THP in one piece
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
Date: Thu, 28 Jun 2018 13:29:09 +0800
In-Reply-To: <20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
	(Andrew Morton's message of "Wed, 27 Jun 2018 21:51:44 -0700")
Message-ID: <87r2krfpi2.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Fri, 22 Jun 2018 11:51:30 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> This is the final step of THP (Transparent Huge Page) swap
>> optimization.  After the first and second step, the splitting huge
>> page is delayed from almost the first step of swapout to after swapout
>> has been finished.  In this step, we avoid splitting THP for swapout
>> and swapout/swapin the THP in one piece.
>
> It's a tremendously good performance improvement.  It's also a
> tremendously large patchset :(
>
> And it depends upon your
> mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch and
> mm-fix-race-between-swapoff-and-mincore.patch, the first of which has
> been floating about since February without adequate review.
>
> I'll give this patchset a spin in -mm to see what happens and will come
> back later to take a closer look.  But the best I can do at this time
> is to hopefully cc some possible reviewers :)

Thanks a lot for your help!  Hope more people can review it!

Best Regards,
Huang, Ying
