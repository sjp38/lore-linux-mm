Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65EB76B0279
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 17:52:33 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p77so7856561ioo.13
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 14:52:33 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id x67si638785itg.101.2017.06.26.14.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 14:52:32 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id 185so1261492itv.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 14:52:32 -0700 (PDT)
Message-ID: <1498513950.22457.4.camel@gmail.com>
Subject: Re: [kees:for-next/fortify 8/8] include/linux/string.h:309:4:
 error: call to '__read_overflow2' declared with attribute error: detected
 read beyond size of object passed as 2nd parameter
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 26 Jun 2017 17:52:30 -0400
In-Reply-To: <20170626144539.1e2f7e07ed9d7063db77d063@linux-foundation.org>
References: <201706250930.6iL2L5TJ%fengguang.wu@intel.com>
	 <20170626144539.1e2f7e07ed9d7063db77d063@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Kees Cook <keescook@chromium.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, 2017-06-26 at 14:45 -0700, Andrew Morton wrote:
> On Sun, 25 Jun 2017 09:16:32 +0800 kbuild test robot <fengguang.wu@int
> el.com> wrote:
> 
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.g
> > it for-next/fortify
> > head:   d481d95b725d2abc7ed31f2f8c4c95c2bd8b0282
> > commit: d481d95b725d2abc7ed31f2f8c4c95c2bd8b0282 [8/8]
> > include/linux/string.h: add the option of fortified string.h
> > functions
> > config: i386-allmodconfig (attached as .config)
> > compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> > reproduce:
> >         git checkout d481d95b725d2abc7ed31f2f8c4c95c2bd8b0282
> >         # save the attached .config to linux build tree
> >         make ARCH=i386 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    In file included from arch/x86/include/asm/page_32.h:34:0,
> >                     from arch/x86/include/asm/page.h:13,
> >                     from arch/x86/include/asm/thread_info.h:11,
> >                     from include/linux/thread_info.h:37,
> >                     from arch/x86/include/asm/preempt.h:6,
> >                     from include/linux/preempt.h:80,
> >                     from include/linux/spinlock.h:50,
> >                     from include/linux/mmzone.h:7,
> >                     from include/linux/gfp.h:5,
> >                     from include/linux/slab.h:14,
> >                     from drivers/scsi/csiostor/csio_lnode.c:37:
> >    In function 'memcpy',
> >        inlined from 'csio_append_attrib' at
> > drivers/scsi/csiostor/csio_lnode.c:248:2,
> 
> hm, this was added by Kees's 42c335f7e6702 ("scsi: csiostor: Avoid
> content leaks and casts").
> 
> I think I'll tend to ignore these odd stragglers now - a few more will
> probably pop up and we can fix them after 4.13-rc1 as they are
> reported.

It's in the scsi for-next tree. The issue that we ran into with fortify
in the kspp tree was that scsi was merged into next after it so tests
still ran into this. I assume that for 4.13-rc1 they'll both be merged
so there shouldn't be a problem then. I'm not very familiar with how the
workflow works or how issues like this should be handled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
