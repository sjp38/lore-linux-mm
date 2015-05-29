Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 33E366B0083
	for <linux-mm@kvack.org>; Fri, 29 May 2015 12:36:07 -0400 (EDT)
Received: by igbjd9 with SMTP id jd9so18592905igb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 09:36:07 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id lr3si5173589icc.83.2015.05.29.09.36.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 09:36:06 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so18371435igb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 09:36:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150529163054.GA4420@infradead.org>
References: <1432912172-16591-1-git-send-email-ddstreet@ieee.org>
 <20150529152241.GA22726@infradead.org> <CALZtONAuMMOfsqLKKUjBKjB7oGkbvYM-RcfyZG3fPn6SPES_iQ@mail.gmail.com>
 <20150529163054.GA4420@infradead.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 29 May 2015 12:35:46 -0400
Message-ID: <CALZtONAWMk1L9r1NRr3FiW-2T020EL7Q5HAt-zwt8D43TfNewg@mail.gmail.com>
Subject: Re: [PATCH] zpool: add EXPORT_SYMBOL for functions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, May 29, 2015 at 12:30 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, May 29, 2015 at 11:36:05AM -0400, Dan Streetman wrote:
>> because they are available for public use, per zpool.h?  If, e.g.,
>> zram ever started using zpool, it would need them exported, wouldn't
>> it?
>
> If you want to use it in ram export it in the same series as those
> changes, and explain what the exprots are for in your message body.
>

I don't want to use it in zram.  I wrote zpool, but neglected to
export the functions.  They should be exported though.

What's your reasoning for not wanting them exported?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
