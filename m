Received: by nf-out-0910.google.com with SMTP id p46so1424887nfa
        for <linux-mm@kvack.org>; Sat, 12 Aug 2006 14:43:46 -0700 (PDT)
Message-ID: <6e88e8570608121443i44991d96y15c4e7ff662f1121@mail.gmail.com>
Date: Sat, 12 Aug 2006 23:43:46 +0200
From: "Nikola Gidalov" <ngidalov@gmail.com>
Subject: mmap maped memory trace
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear kernel experts,

I'd like to ask you how it is possible to to be notified in the driver
module whenever the user of driver writes to the mmap-ed memory from
the driver.

I'm making a virtual 8bpp framebuffer driver. The user of the fb
driver uses mmap to map the framebuffer memory. In the driver I use
the vmalloc memory and map the memory to the user space when the user
calls mmap.
Now , I'd like to intercept the "memory-write" operation to my mmaped
memory, to convert the 8bpp value to 32bpp and to write the 32bpp
value to the real framebuffer on the fly.
Changing the clients to use 32bpp framebuffer directly os not an option.

With kind regards,

Nikola

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
