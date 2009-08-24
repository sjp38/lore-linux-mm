Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CCD886B0104
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 20:41:25 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2298296bwz.38
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:41:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A92D7D4.7020807@vflare.org>
References: <200908241007.47910.ngupta@vflare.org>
	 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
	 <4A92D35F.50604@vflare.org>
	 <84144f020908241108o4d9d6e38wba7806977b8b6073@mail.gmail.com>
	 <4A92D7D4.7020807@vflare.org>
Date: Mon, 24 Aug 2009 21:27:57 +0300
Message-ID: <84144f020908241127vc8dafa4l340d000097cf5548@mail.gmail.com>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 9:11 PM, Nitin Gupta<ngupta@vflare.org> wrote:
>> Is the name rzmalloc() too similar to kzalloc() which stands for
>> zeroing allocator, though? I think I suggested
>> ramzswap_alloc()/ramzswap_free() in the past to avoid confusion. I'd
>> rather go with that if we can't come up with a nice generic name that
>> stands for alloc_part_of_page_including_highmem().
>
> rzs_malloc()/rzs_free() ?

I am not sure what we gain from the shorter and more cryptic "rzs"
prefix compared to "ramzswap" but yeah, it's less likely to be
confused with kzalloc() so I'm okay with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
