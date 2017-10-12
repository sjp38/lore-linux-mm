Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 471A06B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:17:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k4so4053139wmc.20
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:17:34 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id r75si683571wmf.261.2017.10.12.13.17.32
        for <linux-mm@kvack.org>;
        Thu, 12 Oct 2017 13:17:33 -0700 (PDT)
Date: Thu, 12 Oct 2017 22:17:21 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: Kernel freeze on AMD FX-9590 CPU during I/O
Message-ID: <20171012201721.qw7ng6newibksn5f@pd.tnic>
References: <20171012230124.32550187@demfloro.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171012230124.32550187@demfloro.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitrii Tcvetkov <demfloro@demfloro.ru>
Cc: Andy Lutomirski <luto@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 12, 2017 at 11:01:24PM +0300, Dmitrii Tcvetkov wrote:
> Hello,
> 
> Since linux kernel 4.14-rc1 almost any I/O has a chance to freeze kernel
> (no log in /dev/tty0 nor /dev/ttyS0 not netconsole, no ARP answer over
> network) on one of my machines. Compiling linux kernel reproduces the
> issue reliably so far.
> 
> Bisecting between v4.13 and v4.14-rc1 led me to commit
> 94b1b03b519b81c494900cb112aa00ed205cc2d9

There's a candidate fix in case you wanna try it:

https://lkml.kernel.org/r/8eccc9240041ea7cb94624cab8d07e2a6e911ba7.1507567665.git.luto@kernel.org

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
