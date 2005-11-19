Received: by xproxy.gmail.com with SMTP id h31so392478wxd
        for <linux-mm@kvack.org>; Sat, 19 Nov 2005 10:57:19 -0800 (PST)
Message-ID: <1e62d1370511191057i5ab0b4b3ve3c8a2a3dcabe6fe@mail.gmail.com>
Date: Sat, 19 Nov 2005 23:57:19 +0500
From: Fawad Lateef <fawadlateef@gmail.com>
Subject: Re: Kernel tempory memory alloc
In-Reply-To: <437F1E7F.40504@superbug.demon.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <437F1E7F.40504@superbug.demon.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Courtier-Dutton <James@superbug.demon.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/19/05, James Courtier-Dutton <James@superbug.demon.co.uk> wrote:
>
> The IOCTL will be a simple request/response type, so the memory
> allocation will be for a very short time. Which is the correct memory
> api to use when allocating short term temporary memory in the kernel.

I mostly/vastly used and saw memory allocation API "kmalloc" for small
memory allocations. And for short-term and fast memory allocation use
GFP_ATOMIC flag with memory allocation functions!

> Alternatively, is there a way to handle this by simply moving a page
> from user space to kernel space and then back to user space again?
> Thus reducing the amount of memcpy.
>

I think memcpy is not a big-overhead as compare to temporary mapping a
page from user space to kernel space and then unmapping it each time
an ioctl is called, so you might try to constantly share a buffer
between user/kernel space through which you can access data directly
from both spaces (for mapping user page in kernel you can see
get_user_pages) !


--
Fawad Lateef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
