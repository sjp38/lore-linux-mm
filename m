Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EB5206B00B6
	for <linux-mm@kvack.org>; Wed, 27 May 2015 12:05:48 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so1117323pab.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 09:05:48 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id hw10si20738936pbc.241.2015.05.27.09.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 09:05:48 -0700 (PDT)
Received: by pacwv17 with SMTP id wv17so1119320pac.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 09:05:47 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <3176422.FWpfrlzXOV@wuerfel>
Date: Thu, 28 May 2015 01:05:42 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <BE131E88-14CC-4080-AE1E-86EC3E5E3E04@gmail.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <20150527041015.GB11609@blaptop> <20150527062250.GD3928@swordfish> <3176422.FWpfrlzXOV@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, barami97@gmail.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On May 27, 2015, at 4:31 PM, Arnd Bergmann wrote:
> On Wednesday 27 May 2015 15:22:50 Sergey Senozhatsky wrote:
>> On (05/27/15 13:10), Minchan Kim wrote:
>>> On Tue, May 26, 2015 at 08:29:59PM +0900, Jungseok Lee wrote:
>>>>=20
>>>> if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
>>>>    goto nopage;
>>>>=20
>>>> IMHO, a reclaim operation would be not needed in this context if =
memory is
>>>> allocated from vmalloc space. It means there is no need to traverse =
shrinker list.=20
>>>=20
>>> For making fork successful with using vmalloc, it's bandaid.
>=20
> Right.

Thanks for a clear feedback!

It sounds like Catalin's idea should be considered seriously in ARM64 =
perspective.

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
