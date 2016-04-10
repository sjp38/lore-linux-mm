Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 10AE86B0253
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 21:44:14 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n1so99871168pfn.2
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 18:44:14 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id fh8si10341746pab.5.2016.04.09.18.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 18:44:13 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id bx7so81793597pad.3
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 18:44:13 -0700 (PDT)
Date: Sun, 10 Apr 2016 11:41:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2 1/2] lib: lz4: fixed zram with lz4 on big endian
 machines
Message-ID: <20160410024158.GB695@swordfish>
References: <1460235935-1003-1-git-send-email-rsalvaterra@gmail.com>
 <1460235935-1003-2-git-send-email-rsalvaterra@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460235935-1003-2-git-send-email-rsalvaterra@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com, gregkh@linuxfoundation.org, eunb.song@samsung.com, minchan@kernel.org, chanho.min@lge.com, kyungsik.lee@lge.com, stable@vger.kernel.org

On (04/09/16 22:05), Rui Salvaterra wrote:
> Note that the 64-bit preprocessor test is not a cleanup, it's part of
> the fix, since those identifiers are bogus (for example, __ppc64__
> isn't defined anywhere else in the kernel, which means we'd fall into
> the 32-bit definitions on ppc64).

good find.

> Tested on ppc64 with no regression on x86_64.
> 
> [1] http://marc.info/?l=linux-kernel&m=145994470805853&w=4
> 
> Cc: stable@vger.kernel.org
> Suggested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Rui Salvaterra <rsalvaterra@gmail.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
