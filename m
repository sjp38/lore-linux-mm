Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 19DDE6B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 13:20:23 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id r20so5612802wiv.15
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 10:20:22 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id i2si5333991wjn.131.2014.04.01.10.20.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Apr 2014 10:20:21 -0700 (PDT)
Date: Tue, 1 Apr 2014 17:59:47 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH RFC] drivers/char/mem: byte generating devices and
 poisoned mappings
Message-ID: <20140401175947.5b5a3298@alan.etchedpixels.co.uk>
In-Reply-To: <20140331211607.26784.43976.stgit@zurg>
References: <20140331211607.26784.43976.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Yury Gribov <y.gribov@samsung.com>, Alexandr Andreev <aandreev@parallels.com>, Vassili Karpov <av1474@comtv.ru>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, 01 Apr 2014 01:16:07 +0400
Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> This patch adds 256 virtual character devices: /dev/byte0, ..., /dev/byte255.
> Each works like /dev/zero but generates memory filled with particular byte.

More kernel code for an ultra-obscure corner case that can be done in
user space

I don't see the point

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
