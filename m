Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF7F6B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 12:01:45 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id z17-v6so2823733uap.5
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 09:01:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i61-v6sor1914138uad.77.2018.08.03.09.01.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 09:01:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com> <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 3 Aug 2018 19:01:42 +0300
Message-ID: <CAHp75VdkFfND+Mr+L96kkGEF7K49Fr2HWezQQ3DBOQvxTLjBcw@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Fri, Aug 3, 2018 at 6:59 PM, Andy Shevchenko
<andy.shevchenko@gmail.com> wrote:
> On Fri, Aug 3, 2018 at 6:17 PM, Tony Battersby <tonyb@cybernetics.com> wrote:

>> But then I decided to simplify it to just use dev_err().  I still have
>> the old version.  When I submit v3 of the patchset, which would you prefer?
>
> JFYI: git log --no-merges --grep 'NULL device \*'

Example:

commit b4ba97e76763c4e582e3af1079e220e93b1b0d76
Author: Chris Wilson <chris@chris-wilson.co.uk>
Date:   Fri Aug 19 08:37:50 2016 +0100

   drm: Avoid calling dev_printk(.dev = NULL)



> P.S. I already shared my opinion on this anyway.

-- 
With Best Regards,
Andy Shevchenko
