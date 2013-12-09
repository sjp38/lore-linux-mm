Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 622846B0126
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 17:39:43 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so3289516yha.35
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 14:39:43 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id q66si6309397yhm.254.2013.12.09.14.39.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 14:39:42 -0800 (PST)
Message-ID: <52A646AB.1030900@ti.com>
Date: Mon, 9 Dec 2013 17:39:39 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/23] mm/memblock: debug: correct displaying of upper
 memory boundary
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com> <1386625856-12942-2-git-send-email-santosh.shilimkar@ti.com> <20131209215641.GF29143@saruman.home>
In-Reply-To: <20131209215641.GF29143@saruman.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbi@ti.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Monday 09 December 2013 04:56 PM, Felipe Balbi wrote:
> On Mon, Dec 09, 2013 at 04:50:34PM -0500, Santosh Shilimkar wrote:
>> From: Grygorii Strashko <grygorii.strashko@ti.com>
>>
>> When debugging is enabled (cmdline has "memblock=debug") the memblock
>> will display upper memory boundary per each allocated/freed memory range
>> wrongly. For example:
>>  memblock_reserve: [0x0000009e7e8000-0x0000009e7ed000] _memblock_early_alloc_try_nid_nopanic+0xfc/0x12c
>>
>> The 0x0000009e7ed000 is displayed instead of 0x0000009e7ecfff
>>
>> Hence, correct this by changing formula used to calculate upper memory
>> boundary to (u64)base + size - 1 instead of  (u64)base + size everywhere
>> in the debug messages.
>>
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Acked-by: Tejun Heo <tj@kernel.org>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> 
> Very minor patch but perhaps we should Cc: stable here ? not that it
> matters much...
> 
Yeah... No major fix as such from stable perspective.

regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
