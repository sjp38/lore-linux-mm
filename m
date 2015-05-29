Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 263486B0081
	for <linux-mm@kvack.org>; Fri, 29 May 2015 12:31:01 -0400 (EDT)
Received: by pdea3 with SMTP id a3so57085371pde.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 09:31:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id u9si9088178pdp.186.2015.05.29.09.30.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 09:31:00 -0700 (PDT)
Date: Fri, 29 May 2015 09:30:54 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] zpool: add EXPORT_SYMBOL for functions
Message-ID: <20150529163054.GA4420@infradead.org>
References: <1432912172-16591-1-git-send-email-ddstreet@ieee.org>
 <20150529152241.GA22726@infradead.org>
 <CALZtONAuMMOfsqLKKUjBKjB7oGkbvYM-RcfyZG3fPn6SPES_iQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAuMMOfsqLKKUjBKjB7oGkbvYM-RcfyZG3fPn6SPES_iQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, May 29, 2015 at 11:36:05AM -0400, Dan Streetman wrote:
> because they are available for public use, per zpool.h?  If, e.g.,
> zram ever started using zpool, it would need them exported, wouldn't
> it?

If you want to use it in ram export it in the same series as those
changes, and explain what the exprots are for in your message body.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
