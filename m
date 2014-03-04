Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 447F86B0035
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 16:26:07 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so107680pab.5
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 13:26:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id e2si127952pba.181.2014.03.04.13.26.05
        for <linux-mm@kvack.org>;
        Tue, 04 Mar 2014 13:26:06 -0800 (PST)
Date: Tue, 4 Mar 2014 13:26:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: use macros from compiler.h instead of
 __attribute__((...))
Message-Id: <20140304132604.5be1b967068f8e03820d2169@linux-foundation.org>
In-Reply-To: <1393767598-15954-2-git-send-email-gidisrael@gmail.com>
References: <1393767598-15954-1-git-send-email-gidisrael@gmail.com>
	<1393767598-15954-2-git-send-email-gidisrael@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gideon Israel Dsouza <gidisrael@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, geert@linux-m68k.org

On Sun,  2 Mar 2014 19:09:58 +0530 Gideon Israel Dsouza <gidisrael@gmail.com> wrote:

> To increase compiler portability there is <linux/compiler.h> which
> provides convenience macros for various gcc constructs.  Eg: __weak
> for __attribute__((weak)).  I've replaced all instances of gcc
> attributes with the right macro in the memory management
> (/mm) subsystem.
> 
> ...
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -13,6 +13,7 @@
>  #include <linux/nodemask.h>
>  #include <linux/pagemap.h>
>  #include <linux/mempolicy.h>
> +#include <linux/compiler.h>

It may be overdoing things a bit to explicitly include compiler.h. 
It's hard to conceive of any .c file which doesn't already include it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
