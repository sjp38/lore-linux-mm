Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id D17FF6B009E
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 21:20:21 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id x19so554597ier.6
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 18:20:21 -0800 (PST)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id g2si9622982icx.107.2015.01.05.18.20.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 18:20:18 -0800 (PST)
Received: by mail-ig0-f172.google.com with SMTP id hl2so2757118igb.5
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 18:20:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141228235637.GA27095@bbox>
References: <1419599095-4382-1-git-send-email-opensource.ganesh@gmail.com> <20141228235637.GA27095@bbox>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 5 Jan 2015 21:19:51 -0500
Message-ID: <CALZtONATN5xj22qRxFWRXOtpQVRa0LXqLLbv7BKcLuKevKkPqw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/zpool: add name argument to create zpool
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sun, Dec 28, 2014 at 6:56 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Fri, Dec 26, 2014 at 09:04:55PM +0800, Ganesh Mahendran wrote:
>> Currently the underlay of zpool: zsmalloc/zbud, do not know
>> who creates them. There is not a method to let zsmalloc/zbud
>> find which caller they belogs to.
>>
>> Now we want to add statistics collection in zsmalloc. We need
>> to name the debugfs dir for each pool created. The way suggested
>> by Minchan Kim is to use a name passed by caller(such as zram)
>> to create the zsmalloc pool.
>>     /sys/kernel/debug/zsmalloc/zram0
>>
>> This patch adds a argument *name* to zs_create_pool() and other
>> related functions.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Acked-by: Minchan Kim <minchan@kernel.org>

Acked-by: Dan Streetman <ddstreet@ieee.org>

>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
