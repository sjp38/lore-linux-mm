Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7254CC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:01:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 224E420840
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:01:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PLRbMs3A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 224E420840
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B02726B0005; Tue, 13 Aug 2019 12:01:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB3566B0006; Tue, 13 Aug 2019 12:01:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C9426B0007; Tue, 13 Aug 2019 12:01:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1456B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:01:21 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2927A62CA
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:01:21 +0000 (UTC)
X-FDA: 75817869162.13.low63_bbbff493802e
X-HE-Tag: low63_bbbff493802e
X-Filterd-Recvd-Size: 7860
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:01:20 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id gn20so208605plb.2
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:01:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Mm7UG4q/DtA6fInBiZJuiPYlQRUuk6vDEuJqk1ip3QY=;
        b=PLRbMs3Ay6RdcbRE9Hfk9Z9vHcySZVtSRCHFwHVmajim4ZZnICW53fzQzOZOkeS9UL
         Pj9wQ81YvdqtWHh/GaHP7Lkq0/twXx3fFWKw7FGql9hPG9dXAO6VKMHFFpnH+WzZGTEv
         wtu80doHPIgXqiuLRTu4SWdvKTDMgRK89u0x5Od+V6Ab5NIswn3VdR7Jxm5GK6sjXf5B
         OZwCnbyniYeOLrujVO5HY35y6ijwO5L5v2d2DVaySClGfIXLyNZ+mAbxjlCIQ6vpCqtx
         ++fq9aONn0V413p2GfGGZzR3J3M0bn1kov3ajOE3erPSm25ZQ9a71oW8t3VKhOXt0Dxo
         M9OA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Mm7UG4q/DtA6fInBiZJuiPYlQRUuk6vDEuJqk1ip3QY=;
        b=RrCfj4PJc4idaK9BZ6hq4vjqfkC+pW19s29qLEauyyebf5hh57jnU/faPNbrQXAjB0
         oYzO/v675FZO/GUVr5AdqfJesWq3z0+S6xLVqS1HGyKurdjTc908VMiKAD8BBJusaDeE
         JZfiRxaKib5orVo8cv48ZiHVGRE20WRwptAGFThbJ4h/AM+j1SRkvIeYySpXU7zVAKbO
         2dsBSvCArvihnoWwnKGxDqfFRC07px9/cr/yQNL0ldbjGVFT09uClb1B+8lCsPI62Pwb
         botFGABD/f7S/sF1ayPmmyTGWi0kBy3fqiNKVf12mddKvW9/v0X/5jfdU3a+7DptY8jU
         8dAA==
X-Gm-Message-State: APjAAAUSorOiCIfsnjvoJ54uiM34Z5VQu8ZjEWZhmZI8z4pQ8SAXq6f8
	knNuE043ZCKjt104UfKJZP4R+wL91F4bapKGHxFWmQ==
X-Google-Smtp-Source: APXvYqyWE7yMsYI8aUibhFMHiCSSGp500s4otjrr+gQSPER6U5Chnuz9zasWXXl4A271pxoaB2onBkCLmkb7qPYJPyw=
X-Received: by 2002:a17:902:bb94:: with SMTP id m20mr5934626pls.336.1565712079113;
 Tue, 13 Aug 2019 09:01:19 -0700 (PDT)
MIME-Version: 1.0
References: <201908132234.dxi9IQrs%lkp@intel.com>
In-Reply-To: <201908132234.dxi9IQrs%lkp@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 13 Aug 2019 18:01:07 +0200
Message-ID: <CAAeHK+yx4a-P0sDrXTUxMvO2H0CJZUFPffBrg_cU7oJOZyC7ew@mail.gmail.com>
Subject: Re: [rgushchin:fix_vmstats 199/221] lib/strncpy_from_user.c:112:42:
 warning: passing argument 1 of 'untagged_addr' makes integer from pointer
 without a cast
To: kbuild test robot <lkp@intel.com>, Christoph Hellwig <hch@infradead.org>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 4:01 PM kbuild test robot <lkp@intel.com> wrote:
>
> tree:   https://github.com/rgushchin/linux.git fix_vmstats
> head:   4ec858b5201ae067607e82706b36588631c1b990
> commit: f198eb8345ed9cef77b65d1c0edffba3fa3f6d2a [199/221] lib: untag user pointers in strn*_user
> config: sparc64-allmodconfig (attached as .config)
> compiler: sparc64-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout f198eb8345ed9cef77b65d1c0edffba3fa3f6d2a
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=sparc64
>
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>
> All warnings (new ones prefixed by >>):
>
>    lib/strncpy_from_user.c: In function 'strncpy_from_user':
> >> lib/strncpy_from_user.c:112:42: warning: passing argument 1 of 'untagged_addr' makes integer from pointer without a cast [-Wint-conversion]
>      src_addr = (unsigned long)untagged_addr(src);
>                                              ^~~
>    In file included from arch/sparc/include/asm/pgtable.h:5:0,
>                     from include/linux/mm.h:99,
>                     from lib/strncpy_from_user.c:9:
>    arch/sparc/include/asm/pgtable_64.h:1081:29: note: expected 'long unsigned int' but argument is of type 'const char *'
>     static inline unsigned long untagged_addr(unsigned long start)
>                                 ^~~~~~~~~~~~~
> --
>    lib/strnlen_user.c: In function 'strnlen_user':
> >> lib/strnlen_user.c:113:42: warning: passing argument 1 of 'untagged_addr' makes integer from pointer without a cast [-Wint-conversion]
>      src_addr = (unsigned long)untagged_addr(str);
>                                              ^~~
>    In file included from arch/sparc/include/asm/pgtable.h:5:0,
>                     from include/linux/mm.h:99,
>                     from lib/strnlen_user.c:5:
>    arch/sparc/include/asm/pgtable_64.h:1081:29: note: expected 'long unsigned int' but argument is of type 'const char *'
>     static inline unsigned long untagged_addr(unsigned long start)
>                                 ^~~~~~~~~~~~~

This is caused by the difference in untagged_addr() definitions for
sparc and arm64. untagged_addr() for arm64 uses __typeof__ to avoid
casting in places where it is used. Perhaps we should do something
similar for sparc:

diff --git a/arch/sparc/include/asm/pgtable_64.h
b/arch/sparc/include/asm/pgtable_64.h
index 1599de730532..2c4cd82066cb 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -1078,7 +1078,7 @@ static inline int io_remap_pfn_range(struct
vm_area_struct *vma,
 }
 #define io_remap_pfn_range io_remap_pfn_range

-static inline unsigned long untagged_addr(unsigned long start)
+static inline unsigned long __untagged_addr(unsigned long start)
 {
        if (adi_capable()) {
                long addr = start;
@@ -1098,7 +1098,8 @@ static inline unsigned long
untagged_addr(unsigned long start)

        return start;
 }
-#define untagged_addr untagged_addr
+#define untagged_addr(addr) \
+       ((__typeof__(addr))(__untagged_addr((unsigned long)(addr)))

 static inline bool pte_access_permitted(pte_t pte, bool write)
 {

Christoph, WDYT?

>
> vim +/untagged_addr +112 lib/strncpy_from_user.c
>
>     85
>     86  /**
>     87   * strncpy_from_user: - Copy a NUL terminated string from userspace.
>     88   * @dst:   Destination address, in kernel space.  This buffer must be at
>     89   *         least @count bytes long.
>     90   * @src:   Source address, in user space.
>     91   * @count: Maximum number of bytes to copy, including the trailing NUL.
>     92   *
>     93   * Copies a NUL-terminated string from userspace to kernel space.
>     94   *
>     95   * On success, returns the length of the string (not including the trailing
>     96   * NUL).
>     97   *
>     98   * If access to userspace fails, returns -EFAULT (some data may have been
>     99   * copied).
>    100   *
>    101   * If @count is smaller than the length of the string, copies @count bytes
>    102   * and returns @count.
>    103   */
>    104  long strncpy_from_user(char *dst, const char __user *src, long count)
>    105  {
>    106          unsigned long max_addr, src_addr;
>    107
>    108          if (unlikely(count <= 0))
>    109                  return 0;
>    110
>    111          max_addr = user_addr_max();
>  > 112          src_addr = (unsigned long)untagged_addr(src);
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

