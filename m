Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 612A0C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:09:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11D3820663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:09:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="JPzWXPac"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11D3820663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85B1A6B0005; Wed, 17 Apr 2019 10:09:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80A536B0006; Wed, 17 Apr 2019 10:09:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5116B0007; Wed, 17 Apr 2019 10:09:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 472A76B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:09:52 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 10so18369433ybx.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:09:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oObZQK+sHdvnlXjHcYO4raadOnATawKCK6jh/HJoYCM=;
        b=ahfSgXbccxa9/Ssozv62qGKh0OzveawJR0CfweEf1UfqZaB4Fxwzqg8ybtI/2cE1Sw
         jcoHwmsrNWMH80HHYyJAYlBox4xZ2hHe/vY5oJPTyalz7n4Qjsitebc9Qsc3LrH2g8lO
         hiYA/Pm1x3JlJUqeZcjm3zQZTUntgKI4JOb5ZhG+AA9IOcx2O+VJEKkEYlNMP5+ollLr
         quF5PNK5RhLQG88zwDF+3Wdn4r50FgAkwIe2OJbPRHsbJI9LbftQxYr6kX4ka/BGrkQA
         MVEdfPAlpFVJy7SfSr0BWEvmNBpRMmZ60AdTLJlC359/OK2koLTqpcg3wigDWgDV+a6K
         te6g==
X-Gm-Message-State: APjAAAXamW8xW8BvTJfiCoAnACaLpR7flVpDwl2QTDoah7sbKBmXK/J5
	fp9pXEo5BLFsvopyegai/t/q9GgUM7gAsAjPb0DoD4MxMs1f4rx0A0beRkTc5QPKuJO+mdxXgSE
	ZBZWJANVskgbchBNMfMpNZs3neuw3AXU8iz2n0yOEbfB6pMO55EvIRH/+Tu4fm3Z+KQ==
X-Received: by 2002:a81:4d55:: with SMTP id a82mr71123349ywb.271.1555510191949;
        Wed, 17 Apr 2019 07:09:51 -0700 (PDT)
X-Received: by 2002:a81:4d55:: with SMTP id a82mr71123266ywb.271.1555510191083;
        Wed, 17 Apr 2019 07:09:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555510191; cv=none;
        d=google.com; s=arc-20160816;
        b=IDmvQsVHORaCQeVPIPBZ7vsKi+8I4dFeztCfZTumGv0fPFJyMVKQ6VB2QwQ4aVzEyl
         TwddhYxkpqv7ujj4Mx0TDRYFEjeMT7F69oL+jjJJr4NqulRJxqoZZEknHVt9xt0vJjHW
         RuF3c3+9nKAVviz+j8htEzLxKHaJ7XRYnugN58MD0sHH5C9f5upulaYJa8yLn471Cl6J
         IsuAqVOZrOIa/39pf0Xqnkk/CM4mY0+uzecyyKyoj7pz/AajUFZU0wigckOZn26wuySu
         fNtkHRBXMMoMru5z8TOoqXmYf4+52fFawhNwobBzC+MH+CovqxjZnVGZSgZMajuibh5J
         2LLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oObZQK+sHdvnlXjHcYO4raadOnATawKCK6jh/HJoYCM=;
        b=m9JRK44BMZdFMdjhazhfQY5cMVazUav1SaHJeN0rpdR+fYvGAm53DFp3qEWy71uS/b
         z1msxhm8Vxwbr/dijY4b+J0i1hTebcqzYTIhIj//5f24xkC+cvZlXQrgrT2lxtI4vGBl
         segdP/tvSJkV2FK+UYwGx2TUE4FJGylxoBZp0Cd7oYXjJCBlVl6BhTzGrzAiMV8/CZTl
         tXteGfqu6caoRA27wswLJcN67mf9HE2OztiBKMoTU6dudP9gAZRa5uRrQ35EiVpZOvpR
         Uhcnq+8x9YwRtoinCjJOuyzh16PgWUCegYQGbo6EOuKBfZwv58BnUY14WSyUvvVFqm/v
         iuqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JPzWXPac;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor26982911ybe.99.2019.04.17.07.09.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 07:09:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JPzWXPac;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oObZQK+sHdvnlXjHcYO4raadOnATawKCK6jh/HJoYCM=;
        b=JPzWXPactgTw+hSbjU/q0tKHxBGT/agESs5vhPkymth/qmcXBlTUXr2ZkDJuUTBRvn
         ztH+KsumlBSsKrBhwwDqZ9yxv8XjFpWqohWpDDwymsTDoqVvSGrC7yuQYG+kXIxBWkFp
         qv+asCXwQm04J0P/GwCwUzU3OKUzRIY7DiCWQ=
X-Google-Smtp-Source: APXvYqypprrvUaIJ+Wrr3kJMFvrcdtNGBmhwiSTI8Qv5M16m6+w0zw/02N9P7RAjqqefjqONyAU1zQ==
X-Received: by 2002:a25:6544:: with SMTP id z65mr70753868ybb.66.1555510190036;
        Wed, 17 Apr 2019 07:09:50 -0700 (PDT)
Received: from mail-yb1-f172.google.com (mail-yb1-f172.google.com. [209.85.219.172])
        by smtp.gmail.com with ESMTPSA id 80sm12037898ywo.8.2019.04.17.07.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 07:09:49 -0700 (PDT)
Received: by mail-yb1-f172.google.com with SMTP id a13so6203689ybl.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:09:48 -0700 (PDT)
X-Received: by 2002:a25:d947:: with SMTP id q68mr61232872ybg.180.1555510188436;
 Wed, 17 Apr 2019 07:09:48 -0700 (PDT)
MIME-Version: 1.0
References: <201904172010.sZvN8dI5%lkp@intel.com> <CAGXu5jJF-gDUu5v74WzOAb8uGWdQf5Ng79xgjC7qwAjOHO-09g@mail.gmail.com>
In-Reply-To: <CAGXu5jJF-gDUu5v74WzOAb8uGWdQf5Ng79xgjC7qwAjOHO-09g@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 17 Apr 2019 09:09:36 -0500
X-Gmail-Original-Message-ID: <CAGXu5j++mCK1H3n9Z8J0QMOU7b=kXaofYyyJ5H0GdNeDD5c5DQ@mail.gmail.com>
Message-ID: <CAGXu5j++mCK1H3n9Z8J0QMOU7b=kXaofYyyJ5H0GdNeDD5c5DQ@mail.gmail.com>
Subject: Re: [mmotm:master 253/317] arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7:
 error: 'elf_interpreter' undeclared; did you mean 'interpreter'?
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 8:54 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Apr 17, 2019 at 7:34 AM kbuild test robot <lkp@intel.com> wrote:
> >
> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > head:   def6be39d5629b938faba788330db817d19a04da
> > commit: 8e5e08d49bf73afad16199d68c5e61a64f5df69d [253/317] fs/binfmt_elf.c: move brk out of mmap when doing direct loader exec
> > config: mips-fuloong2e_defconfig (attached as .config)
> > compiler: mips64el-linux-gnuabi64-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 8e5e08d49bf73afad16199d68c5e61a64f5df69d
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=7.2.0 make.cross ARCH=mips
> >
> > All errors (new ones prefixed by >>):
> >
> >    In file included from arch/mips/kernel/binfmt_elfn32.c:106:0:
> >    arch/mips/kernel/../../../fs/binfmt_elf.c: In function 'load_elf_binary':
> > >> arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7: error: 'elf_interpreter' undeclared (first use in this function); did you mean 'interpreter'?
> >      if (!elf_interpreter)
> >           ^~~~~~~~~~~~~~~
> >           interpreter
> >    arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7: note: each undeclared identifier is reported only once for each function it appears in
>
> Whoa. That was unexpected (.c getting #included!)
>
> Especially since that's a local variable... I'll try to figure out
> what's happening...

I can't reproduce this on mips-linux-gnu-gcc (Ubuntu
7.3.0-27ubuntu1~18.04) 7.3.0

But I did notice that there is a kfree() _before_ other uses (though
none dereferencing) of elf_interpreter. Perhaps something in the
optimization pass removed the variable?

We could try this, which should likely be fixed regardless...

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index cdaa33f4a3ef..7682d47bd5f0 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1100,7 +1100,6 @@ static int load_elf_binary(struct linux_binprm *bprm)

                allow_write_access(interpreter);
                fput(interpreter);
-               kfree(elf_interpreter);
        } else {
                elf_entry = loc->elf_ex.e_entry;
                if (BAD_ADDR(elf_entry)) {
@@ -1175,6 +1174,7 @@ static int load_elf_binary(struct linux_binprm *bprm)
        start_thread(regs, elf_entry, bprm->p);
        retval = 0;
 out:
+       kfree(elf_interpreter);
        kfree(loc);
 out_ret:
        return retval;


>
> -Kees
>
> >
> > vim +1140 arch/mips/kernel/../../../fs/binfmt_elf.c
> >
> >   1122
> >   1123          retval = create_elf_tables(bprm, &loc->elf_ex,
> >   1124                            load_addr, interp_load_addr);
> >   1125          if (retval < 0)
> >   1126                  goto out;
> >   1127          /* N.B. passed_fileno might not be initialized? */
> >   1128          current->mm->end_code = end_code;
> >   1129          current->mm->start_code = start_code;
> >   1130          current->mm->start_data = start_data;
> >   1131          current->mm->end_data = end_data;
> >   1132          current->mm->start_stack = bprm->p;
> >   1133
> >   1134          /*
> >   1135           * When executing a loader directly (ET_DYN without Interp), move
> >   1136           * the brk area out of the mmap region (since it grows up, and may
> >   1137           * collide early with the stack growing down), and into the unused
> >   1138           * ELF_ET_DYN_BASE region.
> >   1139           */
> > > 1140          if (!elf_interpreter)
> >   1141                  current->mm->brk = current->mm->start_brk = ELF_ET_DYN_BASE;
> >   1142
> >   1143          if ((current->flags & PF_RANDOMIZE) && (randomize_va_space > 1)) {
> >   1144                  current->mm->brk = current->mm->start_brk =
> >   1145                          arch_randomize_brk(current->mm);
> >   1146  #ifdef compat_brk_randomized
> >   1147                  current->brk_randomized = 1;
> >   1148  #endif
> >   1149          }
> >   1150
> >   1151          if (current->personality & MMAP_PAGE_ZERO) {
> >   1152                  /* Why this, you ask???  Well SVr4 maps page 0 as read-only,
> >   1153                     and some applications "depend" upon this behavior.
> >   1154                     Since we do not have the power to recompile these, we
> >   1155                     emulate the SVr4 behavior. Sigh. */
> >   1156                  error = vm_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
> >   1157                                  MAP_FIXED | MAP_PRIVATE, 0);
> >   1158          }
> >   1159
> >
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology Center
> > https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
>
>
> --
> Kees Cook



-- 
Kees Cook

