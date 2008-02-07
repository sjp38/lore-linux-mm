Received: by wa-out-1112.google.com with SMTP id m33so942906wag.8
        for <linux-mm@kvack.org>; Thu, 07 Feb 2008 00:20:08 -0800 (PST)
Message-ID: <ce9e96720802070020y3b7783c0we007f0651629228b@mail.gmail.com>
Date: Thu, 7 Feb 2008 13:50:07 +0530
From: "Vedang - 1337 u|33r h4x0r" <ved.manerikar@gmail.com>
Subject: get_vm_area WITHOUT alloc_pages
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Can I use get_vm_area() to ONLY allocate virtual memory without
calling alloc_pages later? I have the physical address of a page with
me, and I'm going to make a manual entry in the PTE. Will the above
approach have any uncalled for consequences?

I am hacking the paging mechanism, to understand the working, and I
wish to map a physical page to two different virtual addresses without
using standard kernel functions.
-- 
Solaris is simple. It takes a genius to understand it's simplicity.
                                    - Anon
People think it must be fun to be a super genius, but they don't
realize how hard it is to put up with all the idiots in the world.
                                     - Calvin.
Cheers,
Vedang.

B.E. Computer Engineering,
P.I.C.T Pune.
http://blogs.sun.com/vedang
http://dose-of-wisdom.blogspot.com
http://tech-rantings.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
