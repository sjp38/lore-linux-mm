Date: Tue, 26 Sep 2000 10:41:52 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <002001c02756$fe0b5480$671a6e0a@huawei.com.cn>
Subject: Re: How can I support memory hole in embedded system?
Message-Id: <20000926153553Z131166-10399+4@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from "dony" <dony.he@huawei.com> on Tue, 26 Sep 2000
09:13:33 +0800


> In 2.4.0 arch/i386/boot/setup.S, It introduces an method known as
> "E820" which is said to support memory hole .But it uses "int 15" to get
> memory regions  from BIOS which cannot be implemented in my case, since my
> motherboard has no BIOS, only BSP instead.

In that case, you can just write an INT 15-like function which pretends to be a
BIOS, and have the Linux kernel call your function instead of a real INT 15.
Your function than just fills out the E820 structure and returns.

You're going to need to do something like this anyway, because if the kernel
tries to call INT 15 on your machine, it will hang.



-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
