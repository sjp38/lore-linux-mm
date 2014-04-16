Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3CB6B0078
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 12:17:24 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so10993105pbc.7
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 09:17:24 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id gr5si10605231pac.196.2014.04.16.09.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Apr 2014 09:17:23 -0700 (PDT)
Message-ID: <534EAD12.3090602@codeaurora.org>
Date: Wed, 16 Apr 2014 09:17:22 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [next:master 103/113] include/linux/blkdev.h:25:29: fatal error:
 asm/scatterlist.h: No such file or directory
References: <534e2a6e.Ldm85XovY2CX2Ogp%fengguang.wu@intel.com>
In-Reply-To: <534e2a6e.Ldm85XovY2CX2Ogp%fengguang.wu@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On 4/15/2014 11:59 PM, kbuild test robot wrote:
>    In file included from init/main.c:75:0:
>>> >> include/linux/blkdev.h:25:29: fatal error: asm/scatterlist.h: No such file or directory
>     #include <asm/scatterlist.h>
>                                 ^
>    compilation terminated.

The following patch fixes the compile breakage. For my own knowledge, why did this break in
this particular way?

---- 8< -----
