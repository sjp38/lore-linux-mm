Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id EF0566B0255
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 13:59:40 -0500 (EST)
Received: by ioir85 with SMTP id r85so69951707ioi.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:59:40 -0800 (PST)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id 68si14345854iot.191.2015.12.09.10.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 10:59:40 -0800 (PST)
Received: by ioir85 with SMTP id r85so69951417ioi.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:59:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1449300220-30108-1-git-send-email-kuleshovmail@gmail.com>
References: <1449300220-30108-1-git-send-email-kuleshovmail@gmail.com>
Date: Wed, 9 Dec 2015 10:59:40 -0800
Message-ID: <CANMBJr7U3DfsRC4ATx0=d6pVFXGJJAB2qs2sRS1dZ3xV5csZzg@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: use memblock_insert_region() for the empty array
From: Tyler Baker <tyler.baker@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin's boot bot <khilman@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 4 December 2015 at 23:23, Alexander Kuleshov <kuleshovmail@gmail.com> wrote:
> We have the special case for an empty array in the memblock_add_range()
> function. In the same time we have almost the same functional in the
> memblock_insert_region() function. Let's use the memblock_insert_region()
> instead of direct initialization.
>
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

Just to add on to the report from Dan, the kernelci.org boot bot has
also detected ~65 new boot failures in next-20151209[1], which have
been bisected to this patch[2]. It doesn't revert cleanly, so I'm
going to try to clean it up by hand and see if it resolves the issue.

Cheers,

Tyler

[1] http://kernelci.org/boot/all/job/next/kernel/next-20151209/
[2] http://hastebin.com/ufiwonuraw.vhdl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
