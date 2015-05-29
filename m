Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0576B008C
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:36:26 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so17305408igb.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:36:26 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id o19si1816019igt.27.2015.05.29.08.36.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:36:26 -0700 (PDT)
Received: by igbhj9 with SMTP id hj9so17672134igb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:36:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150529152241.GA22726@infradead.org>
References: <1432912172-16591-1-git-send-email-ddstreet@ieee.org> <20150529152241.GA22726@infradead.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 29 May 2015 11:36:05 -0400
Message-ID: <CALZtONAuMMOfsqLKKUjBKjB7oGkbvYM-RcfyZG3fPn6SPES_iQ@mail.gmail.com>
Subject: Re: [PATCH] zpool: add EXPORT_SYMBOL for functions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, May 29, 2015 at 11:22 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, May 29, 2015 at 11:09:32AM -0400, Dan Streetman wrote:
>> Export the zpool functions that should be exported.
>
> Why?

because they are available for public use, per zpool.h?  If, e.g.,
zram ever started using zpool, it would need them exported, wouldn't
it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
