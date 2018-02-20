Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3B4F6B0007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 02:39:28 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id m200so583454lfg.2
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 23:39:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g30sor177142lja.30.2018.02.19.23.39.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Feb 2018 23:39:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201802201156.4Z60eDwx%fengguang.wu@intel.com>
References: <20180219194216.GA26165@jordon-HP-15-Notebook-PC> <201802201156.4Z60eDwx%fengguang.wu@intel.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 20 Feb 2018 13:09:26 +0530
Message-ID: <CAFqt6zagwbvs06yK6KPp1TE5Z-mXzv6Bh2rhFFAyjz3Nh0BXmA@mail.gmail.com>
Subject: Re: [PATCH] mm: zsmalloc: Replace return type int with bool
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, minchan@kernel.org, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com, Linux-MM <linux-mm@kvack.org>

On Tue, Feb 20, 2018 at 9:07 AM, kbuild test robot <lkp@intel.com> wrote:
> Hi Souptick,
>
> Thank you for the patch! Perhaps something to improve:
>
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.16-rc2 next-20180219]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Souptick-Joarder/mm-zsmalloc-Replace-return-type-int-with-bool/20180220-070147
> base:   git://git.cmpxchg.org/linux-mmotm.git master
>
>
> coccinelle warnings: (new ones prefixed by >>)
>
>>> mm/zsmalloc.c:309:65-66: WARNING: return of 0/1 in function 'zs_register_migration' with return type bool
>
> Please review and possibly fold the followup patch.
>

OK, I will send the v2.

> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
