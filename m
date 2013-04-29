Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2FB456B0002
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 22:57:25 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id 16so6761072iea.24
        for <linux-mm@kvack.org>; Sun, 28 Apr 2013 19:57:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201304252120.GII21814.FMJFtHLOOVQFOS@I-love.SAKURA.ne.jp>
References: <201304242108.FDC35910.VJMHFFFSOLOOQt@I-love.SAKURA.ne.jp> <201304252120.GII21814.FMJFtHLOOVQFOS@I-love.SAKURA.ne.jp>
From: Zhan Jianyu <nasa4836@gmail.com>
Date: Mon, 29 Apr 2013 10:56:44 +0800
Message-ID: <CAHz2CGXXbg8P94uLcN0K6yxLYg__HB75tGrpw9xR1Rqn=6ZhGg@mail.gmail.com>
Subject: Re: [linux-next-20130422] Bug in SLAB?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: glommer@parallels.com, cl@linux.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 25, 2013 at 8:20 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Bisection (with a build fix from commit db845067 "slab: Fixup
> CONFIG_PAGE_ALLOC/DEBUG_SLAB_LEAK sections") reached commit e3366016
> "slab: Use common kmalloc_index/kmalloc_size functions".
> Would you have a look at commit e3366016?


Cc:   linux-mm@kvack.org



--

Regards,
Zhan Jianyu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
