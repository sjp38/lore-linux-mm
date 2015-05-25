Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 868BC6B0283
	for <linux-mm@kvack.org>; Mon, 25 May 2015 02:23:29 -0400 (EDT)
Received: by paza2 with SMTP id a2so55409596paz.3
        for <linux-mm@kvack.org>; Sun, 24 May 2015 23:23:29 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id yb2si14730479pbb.177.2015.05.24.23.23.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 May 2015 23:23:28 -0700 (PDT)
Received: by pabru16 with SMTP id ru16so64660263pab.1
        for <linux-mm@kvack.org>; Sun, 24 May 2015 23:23:28 -0700 (PDT)
Date: Mon, 25 May 2015 15:23:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150525062350.GC555@swordfish>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
 <555F2E7C.4090707@samsung.com>
 <20150525061838.GB555@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150525061838.GB555@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Marcin Jabrzyk <m.jabrzyk@samsung.com>, minchan@kernel.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

On (05/25/15 15:18), Sergey Senozhatsky wrote:
> find_backend() returns back to its caller a raw and completely initialized

*UN-initialized.  a typo.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
