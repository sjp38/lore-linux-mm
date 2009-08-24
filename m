Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4D0066B00D2
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:46:50 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2234028bwz.38
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:46:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A92D35F.50604@vflare.org>
References: <200908241007.47910.ngupta@vflare.org>
	 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
	 <4A92D35F.50604@vflare.org>
Date: Mon, 24 Aug 2009 21:08:01 +0300
Message-ID: <84144f020908241108o4d9d6e38wba7806977b8b6073@mail.gmail.com>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi Nitin,

On Mon, Aug 24, 2009 at 8:52 PM, Nitin Gupta<ngupta@vflare.org> wrote:
> I am okay with renaming it to rzmalloc and compiling it with ramzswap
> instead of as separate module.

Is the name rzmalloc() too similar to kzalloc() which stands for
zeroing allocator, though? I think I suggested
ramzswap_alloc()/ramzswap_free() in the past to avoid confusion. I'd
rather go with that if we can't come up with a nice generic name that
stands for alloc_part_of_page_including_highmem().

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
