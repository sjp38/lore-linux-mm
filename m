Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E1D4B6B00A3
	for <linux-mm@kvack.org>; Fri, 29 May 2015 17:37:22 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so1115098pdb.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 14:37:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id np9si10132414pdb.169.2015.05.29.14.37.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 14:37:22 -0700 (PDT)
Date: Fri, 29 May 2015 14:37:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zpool: add EXPORT_SYMBOL for functions
Message-Id: <20150529143720.f660ab8a16aefa816da04a0a@linux-foundation.org>
In-Reply-To: <CALZtONAWMk1L9r1NRr3FiW-2T020EL7Q5HAt-zwt8D43TfNewg@mail.gmail.com>
References: <1432912172-16591-1-git-send-email-ddstreet@ieee.org>
	<20150529152241.GA22726@infradead.org>
	<CALZtONAuMMOfsqLKKUjBKjB7oGkbvYM-RcfyZG3fPn6SPES_iQ@mail.gmail.com>
	<20150529163054.GA4420@infradead.org>
	<CALZtONAWMk1L9r1NRr3FiW-2T020EL7Q5HAt-zwt8D43TfNewg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, 29 May 2015 12:35:46 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> On Fri, May 29, 2015 at 12:30 PM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Fri, May 29, 2015 at 11:36:05AM -0400, Dan Streetman wrote:
> >> because they are available for public use, per zpool.h?  If, e.g.,
> >> zram ever started using zpool, it would need them exported, wouldn't
> >> it?
> >
> > If you want to use it in ram export it in the same series as those
> > changes, and explain what the exprots are for in your message body.
> >
> 
> I don't want to use it in zram.  I wrote zpool, but neglected to
> export the functions.  They should be exported though.
> 
> What's your reasoning for not wanting them exported?

It's just noise which has no value.  Adding exports when there is a
demonstrated need is an OK approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
