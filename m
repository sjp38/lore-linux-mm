Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 819896B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 03:25:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y192so28825626pgd.0
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 00:25:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id bf3si11955647plb.498.2017.10.04.00.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 00:25:56 -0700 (PDT)
Date: Wed, 4 Oct 2017 00:25:53 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
Message-ID: <20171004072553.GA24620@infradead.org>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-5-nicolas.pitre@linaro.org>
 <20171001083052.GB17116@infradead.org>
 <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
 <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr>
 <20171003145732.GA8890@infradead.org>
 <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr>
 <20171003153659.GA31600@infradead.org>
 <nycvar.YSQ.7.76.1710031137580.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710031137580.5407@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, Richard Weinberger <richard.weinberger@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Tue, Oct 03, 2017 at 11:40:28AM -0400, Nicolas Pitre wrote:
> I provided that explanation several times by now in my cover letter. And 
> separately even to you directly at least once.  What else should I do?

You should do the right things instead of stating irrelevant things
in your cover letter.  As said in my last mail: look at the VM_MIXEDMAP
flag and how it is used by DAX, and you'll get out of the vma splitting
business in the fault path.

If the fs/dax.c code scares you take a look at drivers/dax/device.c
instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
