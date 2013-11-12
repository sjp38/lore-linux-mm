Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id D15756B00F2
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 20:24:17 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id xb12so1916426pbc.23
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 17:24:17 -0800 (PST)
Received: from psmtp.com ([74.125.245.193])
        by mx.google.com with SMTP id mj9si17892309pab.16.2013.11.11.17.24.15
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 17:24:16 -0800 (PST)
Message-ID: <5281833C.4010006@codeaurora.org>
Date: Mon, 11 Nov 2013 17:24:12 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC 0/4] Intermix Lowmem and vmalloc
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org> <20131112001315.GD16735@n2100.arm.linux.org.uk>
In-Reply-To: <20131112001315.GD16735@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On 11/11/2013 4:13 PM, Russell King - ARM Linux wrote:
> On Mon, Nov 11, 2013 at 03:26:48PM -0800, Laura Abbott wrote:
>> Hi,
>>
>> This is an RFC for a feature to allow lowmem and vmalloc virtual address space
>> to be intermixed. This has currently only been tested on a narrow set of ARM
>> chips.
>>
>> Currently on 32-bit systems we have
>>
>>
>>                    Virtual                             Physical
>>
>>     PAGE_OFFSET   +--------------+     PHYS_OFFSET   +------------+
>>                   |              |                   |            |
>>                   |              |                   |            |
>>                   |              |                   |            |
>>                   | lowmem       |                   |  direct    |
>>                   |              |                   |   mapped   |
>>                   |              |                   |            |
>>                   |              |                   |            |
>>                   |              |                   |            |
>>                   +--------------+------------------>x------------>
>>                   |              |                   |            |
>>                   |              |                   |            |
>>                   |              |                   |  not-direct|
>>                   |              |                   | mapped     |
>>                   | vmalloc      |                   |            |
>>                   |              |                   |            |
>>                   |              |                   |            |
>>                   |              |                   |            |
>>                   +--------------+                   +------------+
>>
>> Where part of the virtual spaced above PHYS_OFFSET is reserved for direct
>> mapped lowmem and part of the virtual address space is reserved for vmalloc.
>
> Minor nit...
>
> ITYM PAGE_OFFSET here.  vmalloc space doesn't exist in physical memory.
>

Yes, that is a typo.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
