Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2DDE6B0007
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 22:20:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d4-v6so1954411pfn.9
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 19:20:29 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id j10-v6si2350394plg.396.2018.07.03.19.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 19:20:28 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 00/21] mm, THP, swap: Swapout/swapin THP in one piece
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180627215144.73e98b01099191da59bff28c@linux-foundation.org>
	<20180704021153.GA3346@jagdpanzerIV>
Date: Wed, 04 Jul 2018 10:20:25 +0800
In-Reply-To: <20180704021153.GA3346@jagdpanzerIV> (Sergey Senozhatsky's
	message of "Wed, 4 Jul 2018 11:11:53 +0900")
Message-ID: <878t6rvj12.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> writes:

> On (06/27/18 21:51), Andrew Morton wrote:
>> On Fri, 22 Jun 2018 11:51:30 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>> 
>> > This is the final step of THP (Transparent Huge Page) swap
>> > optimization.  After the first and second step, the splitting huge
>> > page is delayed from almost the first step of swapout to after swapout
>> > has been finished.  In this step, we avoid splitting THP for swapout
>> > and swapout/swapin the THP in one piece.
>> 
>> It's a tremendously good performance improvement.  It's also a
>> tremendously large patchset :(
>
> Will zswap gain a THP swap out/in support at some point?
>
>
> mm/zswap.c: static int zswap_frontswap_store(...)
> ...
> 	/* THP isn't supported */
> 	if (PageTransHuge(page)) {
> 		ret = -EINVAL;
> 		goto reject;
> 	}

That's not on my TODO list.  Do you have interest to work on this?

Best Regards,
Huang, Ying
