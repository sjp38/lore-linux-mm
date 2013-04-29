Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id A9F946B0032
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 23:56:51 -0400 (EDT)
Received: from www262.sakura.ne.jp (ksav51.sakura.ne.jp [219.94.192.131])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id r3T3unR2051426
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 12:56:49 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from CLAMP (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id r3T3unfI051421
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 12:56:49 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: [linux-next-20130422] Bug in SLAB?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201304242108.FDC35910.VJMHFFFSOLOOQt@I-love.SAKURA.ne.jp>
	<201304252120.GII21814.FMJFtHLOOVQFOS@I-love.SAKURA.ne.jp>
	<CAHz2CGXXbg8P94uLcN0K6yxLYg__HB75tGrpw9xR1Rqn=6ZhGg@mail.gmail.com>
In-Reply-To: <CAHz2CGXXbg8P94uLcN0K6yxLYg__HB75tGrpw9xR1Rqn=6ZhGg@mail.gmail.com>
Message-Id: <201304291256.BAJ43262.FOFJOSLFMHQtVO@I-love.SAKURA.ne.jp>
Date: Mon, 29 Apr 2013 12:56:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Zhan Jianyu wrote:
> > Bisection (with a build fix from commit db845067 "slab: Fixup
> > CONFIG_PAGE_ALLOC/DEBUG_SLAB_LEAK sections") reached commit e3366016
> > "slab: Use common kmalloc_index/kmalloc_size functions".
> > Would you have a look at commit e3366016?
> 
> 
> Cc:   linux-mm@kvack.org
> 

Thanks for ML for reporting, Zhan.

The thread starts from https://lkml.org/lkml/2013/4/24/234 .
This regression is about to be merged into linux.git.

Problem with debug options turned on:

  It hangs (with CPU#0 spinning) immediately after printing

    Decompressing Linux... Parsing ELF... done.
    Booting the kernel.

  lines.

Problem with debug options turned off:

  kmalloc() triggers oops when the requested size is too large.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
