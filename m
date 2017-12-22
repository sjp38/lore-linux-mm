Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FAE16B0069
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 19:06:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v25so19134579pfg.14
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:06:08 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id d23si6951298pgn.59.2017.12.21.16.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 16:06:07 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/2] mmap.2: MAP_FIXED updated documentation
In-Reply-To: <20171221142416.188c4d49cb225488781ef8b0@linux-foundation.org>
References: <20171213092550.2774-1-mhocko@kernel.org> <20171213093110.3550-1-mhocko@kernel.org> <20171213093110.3550-2-mhocko@kernel.org> <20171213125540.GA18897@amd> <20171213130458.GI25185@dhcp22.suse.cz> <20171213130900.GA19932@amd> <20171213131640.GJ25185@dhcp22.suse.cz> <20171213132105.GA20517@amd> <20171213144050.GG11493@rei> <CAGXu5jLqE6cUxk-Girx6PG7upEzz8jmu1OH_3LVC26iJc2vTxQ@mail.gmail.com> <c7c7a30e-a122-1bbf-88a2-3349d755c62d@gmail.com> <CAGXu5jJ289R9koVoHmxcvUWr6XHSZR2p0qq3WtpNyN-iNSvrNQ@mail.gmail.com> <87po78fe7m.fsf@concordia.ellerman.id.au> <20171221142416.188c4d49cb225488781ef8b0@linux-foundation.org>
Date: Fri, 22 Dec 2017 11:06:01 +1100
Message-ID: <87k1xfpqxi.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Cyril Hrubis <chrubis@suse.cz>, Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Russell
 King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Mike
 Rapoport <rppt@linux.vnet.ibm.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 21 Dec 2017 23:38:37 +1100 Michael Ellerman <mpe@ellerman.id.au> wrote:
>
>> > Andrew, can you s/MAP_FIXED_SAFE/MAP_FIXED_NOREPLACE/g in the series?
>
> Done.

Thanks.

I sent an ack at some point, here's another if you like:

  Acked-by: Michael Ellerman <mpe@ellerman.id.au>

There's also a couple of stray whitespace changes in the version in
linux-next, and some inconsistent whitespace between the various mman.h
changes. Patch below to fix them up if you haven't already.

cheers


diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index bb9ccb5ff3ed..5e362db59780 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -50,7 +50,6 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
-
 #define MAP_FIXED_SAFE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
 /*
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index dedc09ead4cb..a0702506d7c6 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -26,7 +26,6 @@
 #define MAP_NONBLOCK	0x20000		/* do not block on IO */
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
-
 #define MAP_FIXED_SAFE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
 #define MS_SYNC		1		/* synchronous memory sync */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index d21bffd5d3dc..715a2c927e79 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -25,4 +25,5 @@
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
 
+
 #endif /* _UAPI__SPARC_MMAN_H__ */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index da73b6d5dbcd..52f4d21923b3 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -65,7 +65,6 @@
 # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
 #endif
 
-
 /*
  * Flags for msync
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
