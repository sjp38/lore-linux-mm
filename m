Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5DE86B70ED
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:05:51 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w15so18780695qtk.19
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:05:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f19sor19822034qtp.31.2018.12.04.14.05.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 14:05:51 -0800 (PST)
MIME-Version: 1.0
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
 <20181113063601.GT21824@bombadil.infradead.org> <4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
 <20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org>
 <20181204201801.GS10377@bombadil.infradead.org> <CAHp75VeCHnUcE8mfUkx_uXz9_ZoA+hAvVtFiFP+nLj4rJevBdw@mail.gmail.com>
 <495c7e22-9332-1654-9ee0-63c33fae980e@cybernetics.com>
In-Reply-To: <495c7e22-9332-1654-9ee0-63c33fae980e@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Wed, 5 Dec 2018 00:05:39 +0200
Message-ID: <CAHp75VdYZ43NGyu+H9xusUSRX=MFZaDqPEDF_iZDfhmTGDZc1Q@mail.gmail.com>
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of corruption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>

On Tue, Dec 4, 2018 at 11:26 PM Tony Battersby <tonyb@cybernetics.com> wrote:
>
> On 12/4/18 3:30 PM, Andy Shevchenko wrote:
> > On Tue, Dec 4, 2018 at 10:18 PM Matthew Wilcox <willy@infradead.org> wrote:
> >> On Tue, Dec 04, 2018 at 12:14:43PM -0800, Andrew Morton wrote:
> >>> Also, Andy had issues with the v2 series so it would be good to hear an
> >>> update from him?
> >> Certainly.
> > Hmm... I certainly forgot what was long time ago.
> > If I _was_ in Cc list and didn't comment, I'm fine with it.
> >
> v4 of the patchset is the same as v3 but with the last patch dropped.
> Andy had only one minor comment on v3 about the use of division in patch
> #8, to which I replied.  That was back on August 8.

Seems I'm fine with the last version then.

-- 
With Best Regards,
Andy Shevchenko
