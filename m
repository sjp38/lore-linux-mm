Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 648716B0031
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 23:56:46 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id rl12so1223124iec.36
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 20:56:46 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id nz8si17672259icb.33.2014.04.17.20.56.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Apr 2014 20:56:45 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id to1so1219413ieb.34
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 20:56:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1402032014140.29889@eggly.anvils>
References: <000c01cf1b47$ce280170$6a780450$%yang@samsung.com>
	<20140203153628.5e186b0e4e81400773faa7ac@linux-foundation.org>
	<alpine.LSU.2.11.1402032014140.29889@eggly.anvils>
Date: Fri, 18 Apr 2014 11:56:45 +0800
Message-ID: <CAL1ERfO2u838hnY2NVKVd7Tr_=2o=nVpBf_hTKGHms+QFGTFPQ@mail.gmail.com>
Subject: Re: [PATCH 3/8] mm/swap: prevent concurrent swapon on the same
 S_ISBLK blockdev
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Weijie Yang <weijie.yang@samsung.com>, Minchan Kim <minchan@kernel.org>, shli@kernel.org, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjennings@variantweb.net>, Heesub Shin <heesub.shin@samsung.com>, mquzik@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Feb 4, 2014 at 12:20 PM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 3 Feb 2014, Andrew Morton wrote:
>> On Mon, 27 Jan 2014 18:03:04 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:
>>
>> > When swapon the same S_ISBLK blockdev concurrent, the allocated two
>> > swap_info could hold the same block_device, because claim_swapfile()
>> > allow the same holder(here, it is sys_swapon function).
>> >
>> > To prevent this situation, This patch adds swap_lock protect to ensure
>> > we can find this situation and return -EBUSY for one swapon call.
>> >
>> > As for S_ISREG swapfile, claim_swapfile() already prevent this scenario
>> > by holding inode->i_mutex.
>> >
>> > This patch is just for a rare scenario, aim to correct of code.
>> >
>>
>> hm, OK.  Would it be saner to pass a unique `holder' to
>> claim_swapfile()?  Say, `p'?
>>
>> Truly, I am fed up with silly swapon/swapoff races.  How often does
>> anyone call these things?  Let's slap a huge lock around the whole
>> thing and be done with it?
>
> That answer makes me sad: we can't be bothered to get it right,
> even when Weijie goes to the trouble of presenting a series to do so.
> But I sure don't deserve a vote until I've actually looked through it.
>

Hi,

This is a ping email. Could I get some options about these patch series?

Thanks.

> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
