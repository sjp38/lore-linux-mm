Date: Tue, 26 Jun 2001 11:16:30 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <002001c02756$fe0b5480$671a6e0a@huawei.com.cn>
Subject: Re: How can I support memory hole in embedded system?
Message-ID: <XjIWBD.A.CUD.iVLO7@dinero.interactivesi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from "dony" <dony.he@huawei.com> on Tue, 26 Sep 2000
09:13:33 +0800


> I think we can modify the memory-mapping to support memory hole, but
> I don't know how to do it. In mm/bootmem.c it also mentions it can support
> memory hole with no more comments.
>         Can you give me some information in detail about this? Thank you
> very much.

Just modify the E820 structure after setup.S calls the BIOS INT 15 routine.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
