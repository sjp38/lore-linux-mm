Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id DC87D6B026B
	for <linux-mm@kvack.org>; Sat,  9 Nov 2013 14:09:05 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id uo15so3547152pbc.9
        for <linux-mm@kvack.org>; Sat, 09 Nov 2013 11:09:05 -0800 (PST)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id yl8si11035999pab.89.2013.11.09.11.09.03
        for <linux-mm@kvack.org>;
        Sat, 09 Nov 2013 11:09:04 -0800 (PST)
Message-ID: <527E8848.6030307@ti.com>
Date: Sat, 9 Nov 2013 14:08:56 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/24] mm/power: Use memblock apis for early memory allocations
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com> <1383954120-24368-14-git-send-email-santosh.shilimkar@ti.com> <1479529.EjZ9YN8f8I@vostro.rjw.lan>
In-Reply-To: <1479529.EjZ9YN8f8I@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Machek <pavel@ucw.cz>, linux-pm@vger.kernel.org

On Friday 08 November 2013 08:30 PM, Rafael J. Wysocki wrote:
> On Friday, November 08, 2013 06:41:49 PM Santosh Shilimkar wrote:
>> Switch to memblock interfaces for early memory allocator instead of
>> bootmem allocator. No functional change in beahvior than what it is
>> in current code from bootmem users points of view.
>>
>> Archs already converted to NO_BOOTMEM now directly use memblock
>> interfaces instead of bootmem wrappers build on top of memblock. And the
>> archs which still uses bootmem, these new apis just fallback to exiting
>> bootmem APIs.
>>
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Pavel Machek <pavel@ucw.cz>
>> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
>> Cc: linux-pm@vger.kernel.org
>>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> 
> Fine by me, thanks!
> 
Thanks Rafael. I take that as an ack.

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
