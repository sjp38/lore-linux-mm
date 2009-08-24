Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ED1F76B0118
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 23:27:02 -0400 (EDT)
Received: by pxi15 with SMTP id 15so6495253pxi.23
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 20:27:11 -0700 (PDT)
Message-ID: <4A92DEA2.7050000@vflare.org>
Date: Tue, 25 Aug 2009 00:10:34 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
References: <200908241007.47910.ngupta@vflare.org>	 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>	 <4A92D35F.50604@vflare.org>	 <84144f020908241108o4d9d6e38wba7806977b8b6073@mail.gmail.com>	 <4A92D7D4.7020807@vflare.org> <84144f020908241127vc8dafa4l340d000097cf5548@mail.gmail.com>
In-Reply-To: <84144f020908241127vc8dafa4l340d000097cf5548@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On 08/24/2009 11:57 PM, Pekka Enberg wrote:
> On Mon, Aug 24, 2009 at 9:11 PM, Nitin Gupta<ngupta@vflare.org>  wrote:
>>> Is the name rzmalloc() too similar to kzalloc() which stands for
>>> zeroing allocator, though? I think I suggested
>>> ramzswap_alloc()/ramzswap_free() in the past to avoid confusion. I'd
>>> rather go with that if we can't come up with a nice generic name that
>>> stands for alloc_part_of_page_including_highmem().
>>
>> rzs_malloc()/rzs_free() ?
>
> I am not sure what we gain from the shorter and more cryptic "rzs"
> prefix compared to "ramzswap" but yeah, it's less likely to be
> confused with kzalloc() so I'm okay with that.
>

Perhaps, I'm just too bad with naming :)

xvmalloc -> ramzswap_alloc() (compiled with ramzswap instead of as a separate 
module).

BTW, [rzs]control is the name of userspace utility to send ioctl()s to ramzswap.
Somehow, I am happy with rzscontrol name atleast.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
