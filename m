Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 451986B00BA
	for <linux-mm@kvack.org>; Wed, 27 May 2015 12:08:49 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so1181209pac.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 09:08:49 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id od15si12976184pdb.221.2015.05.27.09.08.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 09:08:48 -0700 (PDT)
Received: by pabru16 with SMTP id ru16so1178884pab.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 09:08:48 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20150527041015.GB11609@blaptop>
Date: Thu, 28 May 2015 01:08:43 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <D1AD69AA-8420-4BDD-9BFE-96E52B6AFA2B@gmail.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <20150525144045.GE14922@blaptop> <D5CD4D44-77BC-4817-B9A7-60C0F4AE444F@gmail.com> <20150527041015.GB11609@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, barami97@gmail.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On May 27, 2015, at 1:10 PM, Minchan Kim wrote:
> Hello Jungseok,

Hi, Minchan,

> On Tue, May 26, 2015 at 08:29:59PM +0900, Jungseok Lee wrote:
>> On May 25, 2015, at 11:40 PM, Minchan Kim wrote:
>>> Hello Jungseok,
>>=20
>> Hi, Minchan,
>>=20
>>> On Mon, May 25, 2015 at 01:02:20AM +0900, Jungseok Lee wrote:
>>>> Fork-routine sometimes fails to get a physically contiguous region =
for
>>>> thread_info on 4KB page system although free memory is enough. That =
is,
>>>> a physically contiguous region, which is currently 16KB, is not =
available
>>>> since system memory is fragmented.
>>>=20
>>> Order less than PAGE_ALLOC_COSTLY_ORDER should not fail in current
>>> mm implementation. If you saw the order-2,3 high-order allocation =
fail
>>> maybe your application received SIGKILL by someone. LMK?
>>=20
>> Exactly right. The allocation is failed via the following path.
>>=20
>> if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
>> 	goto nopage;
>>=20
>> IMHO, a reclaim operation would be not needed in this context if =
memory is
>> allocated from vmalloc space. It means there is no need to traverse =
shrinker list.=20
>=20
> For making fork successful with using vmalloc, it's bandaid.

Thanks for clarification!

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
