Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1C606B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:37:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y192so23714521pgd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:37:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 7si200102pgd.489.2017.10.03.08.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:37:01 -0700 (PDT)
Date: Tue, 3 Oct 2017 08:37:00 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
Message-ID: <20171003153659.GA31600@infradead.org>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-5-nicolas.pitre@linaro.org>
 <20171001083052.GB17116@infradead.org>
 <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
 <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr>
 <20171003145732.GA8890@infradead.org>
 <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, Richard Weinberger <richard.weinberger@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Tue, Oct 03, 2017 at 11:30:50AM -0400, Nicolas Pitre wrote:
> Unless you have a better scheme altogether  to suggest of course, given 
> the existing constraints.

I still can't understand why this convoluted fault path that finds
vma, attempts with all kinds of races and then tries to update things
like vm_ops is even nessecary.

We have direct mappings of physical address perfectly working in the
DAX code (even with write support!) or in drivers using remap_pfn_range
so a really good explanation why neither scheme can be used is needed
first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
