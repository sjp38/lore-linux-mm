Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E043C4CEC7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 01:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3ED2206A4
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 01:46:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="C2ObW/Cr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3ED2206A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E2496B0005; Thu, 12 Sep 2019 21:46:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3924A6B0006; Thu, 12 Sep 2019 21:46:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25CE26B0007; Thu, 12 Sep 2019 21:46:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0090.hostedemail.com [216.40.44.90])
	by kanga.kvack.org (Postfix) with ESMTP id 012CF6B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 21:46:08 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 91296181AC9AE
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 01:46:08 +0000 (UTC)
X-FDA: 75928206816.08.pin39_187746ca92d4c
X-HE-Tag: pin39_187746ca92d4c
X-Filterd-Recvd-Size: 7895
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 01:46:08 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id b13so17061723pfo.8
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 18:46:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=V6ZASlvWSN+T484aUlx76RKyuEnQ4L0RkMkGolD8D7c=;
        b=C2ObW/Cr1/1pZMLcduDH2bviiisZSpRBfTvt0UPo2UDygEGZo8w8BLE/XjJuI5lIan
         5ktW6ZwUJLa6fQvfDKOJHZhttSk9eoczn2OfFCy7dcZdaTOlvl223yqarGRgaikBbUje
         I325surmEVTeQ3mXI3lvxonHZjBSc4XotItGw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=V6ZASlvWSN+T484aUlx76RKyuEnQ4L0RkMkGolD8D7c=;
        b=HV0PdpEMo+6aLE+D1RfYoGbBYoB9WlTDwwPzCE4PXYby5z1PubzY+lBKMysWNTiZ5g
         0qYMPZZAaprp6fa2rAM71OogirwkTcUZtDdl0Uk311IRyth0ZSEv9WqK9QuBLnz3LJmf
         Jh76vDasXK4nZaxujUfkNkiESEi9wx13hHOcXlsAUrT4yUX6qBeQmLVhXGD4bvx7Nrs+
         gzqZkcxpV5VJ55wYbaUVHFsi/8A0F96s3tb0TjfaJsHyNfxGYssuiwQs3/KSOiXJfjVx
         lZLety9xd+Pd/c68BbkhzbalKRF2UW2fzZ/GNxYsoitmV1Rujwe2pbLS3Qalh8KwRsuu
         7Ijw==
X-Gm-Message-State: APjAAAVZYHS1FsnmboGMQzeJZ7ip+aOx00rPTSP1lPOuZFRNRnrNn9Pr
	9rc+l7tP5feSNPYNZxShFkvy2Q==
X-Google-Smtp-Source: APXvYqyAo72HjBMEAKSgzzn9KuQ0eevJXBWTCLKHDZFrNtTiatEfNwg15R3m65Y50nu5FukhBI4bPQ==
X-Received: by 2002:a17:90a:2464:: with SMTP id h91mr2192411pje.9.1568339166649;
        Thu, 12 Sep 2019 18:46:06 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id x5sm27484682pfn.149.2019.09.12.18.46.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Sep 2019 18:46:05 -0700 (PDT)
Date: Thu, 12 Sep 2019 18:46:04 -0700
From: Kees Cook <keescook@chromium.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
	X86 ML <x86@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Subject: Re: problem starting /sbin/init (32-bit 5.3-rc8)
Message-ID: <201909121753.C242E16AA@keescook>
References: <a6010953-16f3-efb9-b507-e46973fc9275@infradead.org>
 <201909121637.B9C39DF@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201909121637.B9C39DF@keescook>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2019 at 05:16:02PM -0700, Kees Cook wrote:
> On Thu, Sep 12, 2019 at 02:40:19PM -0700, Randy Dunlap wrote:
> > This is 32-bit kernel, just happens to be running on a 64-bit laptop.
> > I added the debug printk in __phys_addr() just before "[cut here]".
> > 
> > CONFIG_HARDENED_USERCOPY=y
> 
> I can reproduce this under CONFIG_DEBUG_VIRTUAL=y, and it goes back
> to at least to v5.2. Booting with "hardened_usercopy=off" or without
> CONFIG_DEBUG_VIRTUAL makes this go away (since __phys_addr() doesn't
> get called):
> 
> __check_object_size+0xff/0x1b0:
> pfn_to_section_nr at include/linux/mmzone.h:1153
> (inlined by) __pfn_to_section at include/linux/mmzone.h:1291
> (inlined by) virt_to_head_page at include/linux/mm.h:729
> (inlined by) check_heap_object at mm/usercopy.c:230
> (inlined by) __check_object_size at mm/usercopy.c:280
> 
> Is virt_to_head_page() illegal to use under some recently new conditions?

This combination appears to be bugged since the original introduction
of hardened usercopy in v4.8. Is this an untested combination until
now? (I don't usually do tests with CONFIG_DEBUG_VIRTUAL, but I guess
I will from now on!)

Note from the future (i.e. the end of this email where I figure it out):
it turns out it's actually these three together:

CONFIG_HIGHMEM=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_HARDENED_USERCOPY=y

> 
> > The BUG is this line in arch/x86/mm/physaddr.c:
> > 		VIRTUAL_BUG_ON((phys_addr >> PAGE_SHIFT) > max_low_pfn);
> > It's line 83 in my source file only due to adding <linux/printk.h> and
> > a conditional pr_crit() call.

What exactly is this trying to test?

> > [   19.730409][    T1] debug: unmapping init [mem 0xdc7bc000-0xdca30fff]
> > [   19.734289][    T1] Write protecting kernel text and read-only data: 13888k
> > [   19.737675][    T1] rodata_test: all tests were successful
> > [   19.740757][    T1] Run /sbin/init as init process
> > [   19.792877][    T1] __phys_addr: max_low_pfn=0x36ffe, x=0xff001ff1, phys_addr=0x3f001ff1

It seems like this address is way out of range of the physical memory.
That seems like it's vmalloc or something, but that was actually
explicitly tested for back in the v4.8 version (it became unneeded
later).

> > [   19.796561][    T1] ------------[ cut here ]------------
> > [   19.797501][    T1] kernel BUG at ../arch/x86/mm/physaddr.c:83!
> > [   19.802799][    T1] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [   19.803782][    T1] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 5.3.0-rc8 #6
> > [   19.803782][    T1] Hardware name: Dell Inc. Inspiron 1318                   /0C236D, BIOS A04 01/15/2009
> > [   19.803782][    T1] EIP: __phys_addr+0xaf/0x100
> > [   19.803782][    T1] Code: 85 c0 74 67 89 f7 c1 ef 0c 39 f8 73 2e 56 53 50 68 90 9f 1f dc 68 00 eb 45 dc e8 ec b3 09 00 83 c4 14 3b 3d 30 55 cf dc 76 11 <0f> 0b b8 7c 3b 5c dc e8 45 53 4c 00 90 8d 74 26 00 89 d8 e8 39 cd
> > [   19.803782][    T1] EAX: 00000044 EBX: ff001ff1 ECX: 00000000 EDX: db90a471
> > [   19.803782][    T1] ESI: 3f001ff1 EDI: 0003f001 EBP: f41ddea0 ESP: f41dde90
> > [   19.803782][    T1] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00010216
> > [   19.803782][    T1] CR0: 80050033 CR2: dc218544 CR3: 1ca39000 CR4: 000406d0
> > [   19.803782][    T1] Call Trace:
> > [   19.803782][    T1]  __check_object_size+0xaf/0x3c0
> > [   19.803782][    T1]  ? __might_sleep+0x80/0xa0
> > [   19.803782][    T1]  copy_strings+0x1c2/0x370

Oh, this is actually copying into a kmap() pointer due to the weird
stuff exec() does:

                        kaddr = kmap(kmapped_page);
                ...
                if (copy_from_user(kaddr+offset, str, bytes_to_copy)) {

> > [   19.803782][    T1]  copy_strings_kernel+0x2b/0x40
> > 
> > Full boot log or kernel .config file are available if wanted.

Is kmap somewhere "unexpected" in this case? Ah-ha, yes, it seems it is.
There is even a helper to do the "right" thing as virt_to_page(). This
seems to be used very rarely in the kernel... is there a page type for
kmap pages? This seems like a hack, but it fixes it:


diff --git a/mm/usercopy.c b/mm/usercopy.c
index 98e924864554..5a14b80ad63e 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -11,6 +11,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
 #include <linux/sched/task.h>
@@ -227,7 +228,7 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
 	if (!virt_addr_valid(ptr))
 		return;
 
-	page = virt_to_head_page(ptr);
+	page = compound_head(kmap_to_page((void *)ptr));
 
 	if (PageSlab(page)) {
 		/* Check slab allocator for flags and size. */


What's the right way to "ignore" the kmap range? (i.e. it's not Slab, so
ignore it here: I can't find a page type nor a "is this kmap?" helper...)

-- 
Kees Cook

