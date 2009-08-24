Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9D2C86B010C
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 21:25:43 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id m16so585050waf.22
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:25:46 -0700 (PDT)
Message-ID: <4A92D35F.50604@vflare.org>
Date: Mon, 24 Aug 2009 23:22:31 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
References: <200908241007.47910.ngupta@vflare.org> <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
In-Reply-To: <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi Pekka,

On 08/24/2009 11:03 PM, Pekka Enberg wrote:
>
> [ Nit: the name xmalloc() is usually reserved for non-failing allocators in
>    user-space which is why xvmalloc() looks so confusing to me. Can we
>    get a better name for the thing? Also, I'm not sure why xvmalloc is a
>    separate module. Can't you just make it in-kernel or compile it in to the
>    ramzswap module? ]
>

xvmalloc is still a separate module to make sure I do not make it ramzswap
specific.

I am okay with renaming it to rzmalloc and compiling it with ramzswap instead
of as separate module. I will make these changes in next revision of these
patches.

Thanks,
Nitin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
