Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9861FC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 498D420872
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:54:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="X2nggog4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 498D420872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBEA06B0003; Wed, 17 Apr 2019 09:54:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6CFC6B0006; Wed, 17 Apr 2019 09:54:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C359A6B0007; Wed, 17 Apr 2019 09:54:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC356B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:54:38 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 10so18335009ybx.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:54:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eg//jVPT1FYT/FWLEXwqKtiIyUlBkx9eunnEk0OOm6M=;
        b=bFuqvdzc/ToI5TcTXHAIMbmxKLulFR2Lc1xam5bVJ656JGPETM6HsEWCxcrkhFPcdm
         XglbRodizVb3uwLkTpcS9wUscRfZ3670HwrIR/tcxhrISn1qB+DPr/2tOv1oM6HTMrp1
         H606+vlatZ/iEoPZ6u9bIFEoRS2ABytQjyssDwg0P3GVGSP6MUoIoZqeYung2ioSaPnW
         xbx0JWW51X4NCLIx6BzVvetp8yn4p8HyeqE37FscKqdl3LRQH8zVcRXy/3Q2nk1uSb1n
         KyYfgM0yhYgGCTHedGWamjM474zuqeCvX7rzRAI+O+n9zbC7EX+z/FA0xPMxQ9ShR8VX
         NcEg==
X-Gm-Message-State: APjAAAU4y42qBQQwmVZIyoqmE2qMcR2A1LM6aMl5v7ovHtXVeNH/tspW
	VRQW5krMZq94XEGuNt2pp8XRIrVad4R3dnfa+wXRreXmn2XkJ+fPco58Wv+eAxJz+mvp6+cMVaN
	eXtGVf++N9k9DdeNmXpwoK4qfDS9iEAqYsqlEVNgL1vbKm2c862tBTTGkt5xFKhHVEg==
X-Received: by 2002:a81:794e:: with SMTP id u75mr70594906ywc.226.1555509278328;
        Wed, 17 Apr 2019 06:54:38 -0700 (PDT)
X-Received: by 2002:a81:794e:: with SMTP id u75mr70594858ywc.226.1555509277522;
        Wed, 17 Apr 2019 06:54:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555509277; cv=none;
        d=google.com; s=arc-20160816;
        b=rwlwOU8c65GcNGw9/EdmPod6dJM5zRwda3Cfr7OWvq6Jpx/kiIZAYd71xNZA5c5BO/
         crKIDfV/7tQ6f4gYxrAv3Th9ufGeG9nLbvcvlNND7+DxnO3yUH/AJqrgDoL+euqyObUM
         fsKym0aDht4PC9+0HG46IXkXpjPU1rKyVSuV1tFWHDCyniC0+dOzFOIwoMre3BTKbThW
         E2ykw6+lkR+S5/Lmuq8BF2usoQcZaZiw831/AiT2XVUNG/ktC4kvtBDYs8VdlLXK4dpx
         SelUm1WVQjsQz2MOb2wj2A91gJxhQlGhzep4fxVFHjg1D62p6LMKbo5ww0MQZKwHr5wP
         aj0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eg//jVPT1FYT/FWLEXwqKtiIyUlBkx9eunnEk0OOm6M=;
        b=WUKWOZghCvfyXuKbebkKzRDDRQxRlThuM7tj66cIrLj69tfzE0AGdLAFvMl6M6Hnhk
         sAwihR6df1RBhBVul9VWLR3Bz5f1wTguGiYLYm6NqZymgsD1qx5g+jhCsQ19+8FOWb7z
         tvpBw6eCOzl7jmJo6W3IsUdQQVw2LEjt/T+vlYN5IVN5nXmiP4twrkH2Tb8wAAqHzKM0
         6RDbyKWLX8IQLliL9XlLQpWKz5wZwswlCnL9cL184lz5db4XkpkMUM+o72cUKzeURKIy
         3NeJOsBuBhqapndaRa1a2KXWFYJWHqNtvqUJjzSXMekgicfH77ZgO9dMJ+97cK8G7AOJ
         W3KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=X2nggog4;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185sor1454652ybz.68.2019.04.17.06.54.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 06:54:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=X2nggog4;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eg//jVPT1FYT/FWLEXwqKtiIyUlBkx9eunnEk0OOm6M=;
        b=X2nggog4jsWwso9/sWFJivI+R8AWR/ktNvDiUDPQYrUvC/MfMoXYsTYtzqsKknGJkz
         ZojuGiVlWmeyMUYISrP74ZWYanvhm+6Lz+QZpPtowiBYIIKfM4P0LANqLFshYjzYROsi
         h0SDGR3Mttv8+00QokaEN0zL8eEyIhslDfSiU=
X-Google-Smtp-Source: APXvYqwUN4+KOx40tLVDSk6MptjczGnGEOBSeyxITpQM2JaZ3LYlZXyZYWobRJZBBrzvNdG++lsrfw==
X-Received: by 2002:a25:db51:: with SMTP id g78mr45097183ybf.146.1555509276420;
        Wed, 17 Apr 2019 06:54:36 -0700 (PDT)
Received: from mail-yw1-f50.google.com (mail-yw1-f50.google.com. [209.85.161.50])
        by smtp.gmail.com with ESMTPSA id 143sm13422194yws.92.2019.04.17.06.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:54:35 -0700 (PDT)
Received: by mail-yw1-f50.google.com with SMTP id u197so8615593ywf.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:54:35 -0700 (PDT)
X-Received: by 2002:a81:6f56:: with SMTP id k83mr69664148ywc.105.1555509274610;
 Wed, 17 Apr 2019 06:54:34 -0700 (PDT)
MIME-Version: 1.0
References: <201904172010.sZvN8dI5%lkp@intel.com>
In-Reply-To: <201904172010.sZvN8dI5%lkp@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 17 Apr 2019 08:54:20 -0500
X-Gmail-Original-Message-ID: <CAGXu5jJF-gDUu5v74WzOAb8uGWdQf5Ng79xgjC7qwAjOHO-09g@mail.gmail.com>
Message-ID: <CAGXu5jJF-gDUu5v74WzOAb8uGWdQf5Ng79xgjC7qwAjOHO-09g@mail.gmail.com>
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

On Wed, Apr 17, 2019 at 7:34 AM kbuild test robot <lkp@intel.com> wrote:
>
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   def6be39d5629b938faba788330db817d19a04da
> commit: 8e5e08d49bf73afad16199d68c5e61a64f5df69d [253/317] fs/binfmt_elf.c: move brk out of mmap when doing direct loader exec
> config: mips-fuloong2e_defconfig (attached as .config)
> compiler: mips64el-linux-gnuabi64-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 8e5e08d49bf73afad16199d68c5e61a64f5df69d
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=mips
>
> All errors (new ones prefixed by >>):
>
>    In file included from arch/mips/kernel/binfmt_elfn32.c:106:0:
>    arch/mips/kernel/../../../fs/binfmt_elf.c: In function 'load_elf_binary':
> >> arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7: error: 'elf_interpreter' undeclared (first use in this function); did you mean 'interpreter'?
>      if (!elf_interpreter)
>           ^~~~~~~~~~~~~~~
>           interpreter
>    arch/mips/kernel/../../../fs/binfmt_elf.c:1140:7: note: each undeclared identifier is reported only once for each function it appears in

Whoa. That was unexpected (.c getting #included!)

Especially since that's a local variable... I'll try to figure out
what's happening...

-Kees

>
> vim +1140 arch/mips/kernel/../../../fs/binfmt_elf.c
>
>   1122
>   1123          retval = create_elf_tables(bprm, &loc->elf_ex,
>   1124                            load_addr, interp_load_addr);
>   1125          if (retval < 0)
>   1126                  goto out;
>   1127          /* N.B. passed_fileno might not be initialized? */
>   1128          current->mm->end_code = end_code;
>   1129          current->mm->start_code = start_code;
>   1130          current->mm->start_data = start_data;
>   1131          current->mm->end_data = end_data;
>   1132          current->mm->start_stack = bprm->p;
>   1133
>   1134          /*
>   1135           * When executing a loader directly (ET_DYN without Interp), move
>   1136           * the brk area out of the mmap region (since it grows up, and may
>   1137           * collide early with the stack growing down), and into the unused
>   1138           * ELF_ET_DYN_BASE region.
>   1139           */
> > 1140          if (!elf_interpreter)
>   1141                  current->mm->brk = current->mm->start_brk = ELF_ET_DYN_BASE;
>   1142
>   1143          if ((current->flags & PF_RANDOMIZE) && (randomize_va_space > 1)) {
>   1144                  current->mm->brk = current->mm->start_brk =
>   1145                          arch_randomize_brk(current->mm);
>   1146  #ifdef compat_brk_randomized
>   1147                  current->brk_randomized = 1;
>   1148  #endif
>   1149          }
>   1150
>   1151          if (current->personality & MMAP_PAGE_ZERO) {
>   1152                  /* Why this, you ask???  Well SVr4 maps page 0 as read-only,
>   1153                     and some applications "depend" upon this behavior.
>   1154                     Since we do not have the power to recompile these, we
>   1155                     emulate the SVr4 behavior. Sigh. */
>   1156                  error = vm_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
>   1157                                  MAP_FIXED | MAP_PRIVATE, 0);
>   1158          }
>   1159
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



-- 
Kees Cook

