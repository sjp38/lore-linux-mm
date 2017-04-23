Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB4246B02E1
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 06:53:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k14so12913023wrc.16
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 03:53:56 -0700 (PDT)
Received: from outpost3.zedat.fu-berlin.de (outpost3.zedat.fu-berlin.de. [130.133.4.78])
        by mx.google.com with ESMTPS id a40si1585182edd.114.2017.04.23.03.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Apr 2017 03:53:55 -0700 (PDT)
From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Subject: Question on the five-level page table support patches
Message-ID: <030ea57b-5f6c-13d8-02f7-b245a754a87d@physik.fu-berlin.de>
Date: Sun, 23 Apr 2017 12:53:46 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org

Hi Kirill!

I recently read the LWN article on your and your colleagues work to
add five-level page table support for x86 to the Linux kernel [1]
and I got your email address from the last patch of the series.

Since this extends the address space beyond 48-bits, as you may know,
it will cause potential headaches with Javascript engines which use
tagged pointers. On SPARC, the virtual address space already extends
to 52 bits and we are running into these very issues with Javascript
engines on SPARC.

Now, a possible way to mitigate this problem would be to pass the
"hint" parameter to mmap() in order to tell the kernel not to allocate
memory beyond the 48 bits address space. Unfortunately, on Linux this
will only work when the area pointed to by "hint" is unallocated which
means one cannot simply use a hardcoded "hint" to mitigate this problem.

However, since this trick still works on NetBSD and used to work on
Linux [3], I was wondering whether there are plans to bring back
this behavior to mmap() in Linux.

Currently, people are using ugly work-arounds [4] to address this
problem which involve a manual iteration over memory blocks and
basically implementing another allocator in the user space
application.

Thanks,
Adrian

> [1] https://lwn.net/Articles/717293/
> [2] https://lwn.net/Articles/717300/
> [3] https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=824449#22
> [4] https://hg.mozilla.org/mozilla-central/rev/dfaafbaaa291

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
