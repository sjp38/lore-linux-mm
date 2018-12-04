Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 453936B7091
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:30:50 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 92so18007174qkx.19
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:30:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i185sor10040985qkf.124.2018.12.04.12.30.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 12:30:49 -0800 (PST)
MIME-Version: 1.0
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
 <20181113063601.GT21824@bombadil.infradead.org> <4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
 <20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org> <20181204201801.GS10377@bombadil.infradead.org>
In-Reply-To: <20181204201801.GS10377@bombadil.infradead.org>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Tue, 4 Dec 2018 22:30:37 +0200
Message-ID: <CAHp75VeCHnUcE8mfUkx_uXz9_ZoA+hAvVtFiFP+nLj4rJevBdw@mail.gmail.com>
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of corruption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Battersby <tonyb@cybernetics.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>

On Tue, Dec 4, 2018 at 10:18 PM Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, Dec 04, 2018 at 12:14:43PM -0800, Andrew Morton wrote:

> > Also, Andy had issues with the v2 series so it would be good to hear an
> > update from him?
>
> Certainly.

Hmm... I certainly forgot what was long time ago.
If I _was_ in Cc list and didn't comment, I'm fine with it.

-- 
With Best Regards,
Andy Shevchenko
