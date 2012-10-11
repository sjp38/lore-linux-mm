Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C5D186B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 10:19:32 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so1235838wey.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 07:19:31 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 11 Oct 2012 11:19:30 -0300
Message-ID: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
Subject: [Q] Default SLAB allocator
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

Hello,

While I've always thought SLUB was the default and recommended allocator,
I'm surprise to find that it's not always the case:

$ find arch/*/configs -name "*defconfig" | wc -l
452

$ grep -r "SLOB=y" arch/*/configs/ | wc -l
11

$ grep -r "SLAB=y" arch/*/configs/ | wc -l
245

This shows that, SLUB being the default, there are actually more
defconfigs that choose SLAB.

I wonder...

* Is SLAB a proper choice? or is it just historical an never been re-evaluated?
* Does the average embedded guy knows which allocator to choose
  and what's the impact on his platform?

Thanks,

   Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
