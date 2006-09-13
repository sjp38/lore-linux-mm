Received: by py-out-1112.google.com with SMTP id c59so3084596pyc
        for <Linux-MM@kvack.org>; Wed, 13 Sep 2006 07:54:20 -0700 (PDT)
Message-ID: <34a75100609130754t24b8bde6xcebda4f0684c51cb@mail.gmail.com>
Date: Wed, 13 Sep 2006 23:54:19 +0900
From: girish <girishvg@gmail.com>
Subject: why inode creation with GFP_HIGHUSER?
In-Reply-To: <34a75100609130734m68729bdaj30258c10edfa7947@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <34a75100609130734m68729bdaj30258c10edfa7947@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

[hello world. my first mail  linux-mm]

i am following a trail of high-memory initialization on a MIPS32 based
system. i came across inode initialization.

i'd like to know why page(s) for inodes are allocated with
GFP_HIGHUSER & not with GFP_USER mask? is there any particular need
that the address_space be set with GFP_HIGHUSER flag?

(ref: http://lxr.free-electrons.com/source/fs/inode.c#150)
(ref: http://lxr.free-electrons.com/source/include/linux/pagemap.h#031)

i intend to allocate highmem pages strictly to user processes. my idea
is to completely avoid kernel mapping for these pages. so, as a dirty
hack - i changed mapping_set_gfp_mask function not to honor
__GFP_HIGHMEM zone selector if __GFP_IO | __GFP_FS are set. in short i
replace  GFP_HIGHUSER with GFP_USER mask. with this change the kernel
comes to life. but i am still confused about the effect of this change
on system, that i am yet to see?

any help in this regards will be greatly appreciated.

thanks in advance.
girish.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
