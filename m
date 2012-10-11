Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 9ACEA6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 18:42:39 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Q] Default SLAB allocator
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
Date: Thu, 11 Oct 2012 15:42:38 -0700
In-Reply-To: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	(Ezequiel Garcia's message of "Thu, 11 Oct 2012 11:19:30 -0300")
Message-ID: <m27gqwtyu9.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

Ezequiel Garcia <elezegarcia@gmail.com> writes:

> Hello,
>
> While I've always thought SLUB was the default and recommended allocator,
> I'm surprise to find that it's not always the case:

iirc the main performance reasons for slab over slub have mostly
disappeared, so in theory slab could be finally deprecated now.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
