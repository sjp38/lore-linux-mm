Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF586B0136
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 19:39:52 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id r5so3385752qcx.28
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 16:39:51 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id v3si9231175qat.69.2013.12.09.16.39.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 16:39:51 -0800 (PST)
Message-ID: <52A662D2.9010201@ti.com>
Date: Mon, 9 Dec 2013 19:39:46 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com> <529217C7.6030304@cogentembedded.com> <52935762.1080409@ti.com> <20131125155629.GA24344@htj.dyndns.org>
In-Reply-To: <20131125155629.GA24344@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Andrew,

On Monday 25 November 2013 10:56 AM, Tejun Heo wrote:
> On Mon, Nov 25, 2013 at 08:57:54AM -0500, Santosh Shilimkar wrote:
>> On Sunday 24 November 2013 10:14 AM, Sergei Shtylyov wrote:
>>> Hello.
>>>
>>> On 24-11-2013 3:28, Santosh Shilimkar wrote:
>>>
>>>> Building ARM with NO_BOOTMEM generates below warning. Using min_t
>>>
>>>    Where is that below? :-)
>>>
>> Damn.. Posted a wrong version of the patch ;-(
>> Here is the one with warning message included.
>>
>> From 571dfdf4cf8ac7dfd50bd9b7519717c42824f1c3 Mon Sep 17 00:00:00 2001
>> From: Santosh Shilimkar <santosh.shilimkar@ti.com>
>> Date: Sat, 23 Nov 2013 18:16:50 -0500
>> Subject: [PATCH] mm: nobootmem: avoid type warning about alignment value
>>
>> Building ARM with NO_BOOTMEM generates below warning.
>>
>> mm/nobootmem.c: In function a??__free_pages_memorya??:
>> mm/nobootmem.c:88:11: warning: comparison of distinct pointer types lacks a cast
>>
>> Using min_t to find the correct alignment avoids the warning.
>>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> 
Can you please this warning fix as well in your mm tree ?

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
