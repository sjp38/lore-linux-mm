Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6CC626B02DF
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 23:38:07 -0400 (EDT)
Received: by qwk4 with SMTP id 4so9493144qwk.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 20:38:18 -0700 (PDT)
Message-ID: <4C60C9C4.4000902@vflare.org>
Date: Tue, 10 Aug 2010 09:08:44 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] Remove need for explicit device initialization
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>	<1281374816-904-3-git-send-email-ngupta@vflare.org> <AANLkTinsoHUb307N+v6pGfRraHK-epBU70fD0FxPCNup@mail.gmail.com>
In-Reply-To: <AANLkTinsoHUb307N+v6pGfRraHK-epBU70fD0FxPCNup@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/10/2010 12:06 AM, Pekka Enberg wrote:
> On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
>> Currently, the user has to explicitly write a positive value to
>> initstate sysfs node before the device can be used. This event
>> triggers allocation of per-device metadata like memory pool,
>> table array and so on.
>>
>> We do not pre-initialize all zram devices since the 'table' array,
>> mapping disk blocks to compressed chunks, takes considerable amount
>> of memory (8 bytes per page). So, pre-initializing all devices will
>> be quite wasteful if only few or none of the devices are actually
>> used.
>>
>> This explicit device initialization from user is an odd requirement and
>> can be easily avoided. We now initialize the device when first write is
>> done to the device.
>>
>> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> 
> AFAICT, most hardware block device drivers do things like this in the
> probe function. Why can't we do that for zram as well and drop the
> ->init_done and ->init_lock parts?
> 

I think probe is only for PCI devices? Maybe should hook into open function
in struct block_device_operations. That way, we can also drop init_done and
init_lock parts.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
