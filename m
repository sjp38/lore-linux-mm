Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3B8576B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:07:38 -0500 (EST)
Received: by fxm24 with SMTP id 24so2099418fxm.11
        for <linux-mm@kvack.org>; Tue, 19 Jan 2010 06:07:36 -0800 (PST)
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100119075205.GI14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
	 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
	 <20100118141938.GI30698@redhat.com>
	 <84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
	 <20100118170816.GA22111@redhat.com>
	 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
	 <20100118181942.GD22111@redhat.com>
	 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
	 <20100119071734.GG14345@redhat.com>
	 <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
	 <20100119075205.GI14345@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jan 2010 23:07:23 +0900
Message-ID: <1263910043.2163.24.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-19 at 09:52 +0200, Gleb Natapov wrote:

> In my case (virtualization) I want to test/profile guest under heavy swapping
> of a guests memory, so I intentionally create memory shortage by creating

You mean "guest memory" that is area emulated DRAM in qemu?
It is anonymous vma. 

> guest much large then host memory, but I want system to swap out only
> guest's memory.

Couldn't you use MADV_SEQUENTIAL on only guest memory area?
It doesn't make side effect about readahead since it's anon area. 
And it would make do best effort to swap out guest's memory.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
