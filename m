Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E1CAA6B005D
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:41:56 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so2799162yxh.26
        for <linux-mm@kvack.org>; Fri, 29 May 2009 22:42:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090528162108.a6adcc36.kamezawa.hiroyu@jp.fujitsu.com>
References: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
	 <20090528143524.e8a2cde7.kamezawa.hiroyu@jp.fujitsu.com>
	 <202cde0e0905280002o5614f279r9db7c8c52ad7df10@mail.gmail.com>
	 <20090528162108.a6adcc36.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 30 May 2009 17:42:35 +1200
Message-ID: <202cde0e0905292242k313148b8nbc1a47e558f97a1c@mail.gmail.com>
Subject: Re: Inconsistency (bug) of vm_insert_page with high order allocations
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

Kame San,

Thank you for your answers. I've decided to use split_pages function.
>
>  - write a patch for adding alloc_page_exact_nodemask()  // this is not difficult.
>  - explain why you need this.
>  - discuss.
>
Writing the patch is not dificult - but it will be hard to explain why
it is necessary in kernel...
> IMHO, considering other mmap/munmap/zap_pte, etc... page_count() and page_mapocunt()
> should be controlled per pte. Then, you'll have to map pages one by one.
>
This is quite interesting. I tried to understand this code but it is
much complicated. I clearly understand why pages have to be mapped one
by one. By I don't understand how counters relate to this. (it is just
a curiosity question - I won't be upset if no one answer it)

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
