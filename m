Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9FD56B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 12:10:22 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l23-v6so4684858qtp.1
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 09:10:22 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id g1-v6si4814234qkd.118.2018.08.03.09.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 09:10:21 -0700 (PDT)
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
 <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
 <CAHp75VdkFfND+Mr+L96kkGEF7K49Fr2HWezQQ3DBOQvxTLjBcw@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <f5e210ae-e932-4b3a-6774-082e8ddce79e@cybernetics.com>
Date: Fri, 3 Aug 2018 12:10:19 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75VdkFfND+Mr+L96kkGEF7K49Fr2HWezQQ3DBOQvxTLjBcw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 08/03/2018 12:01 PM, Andy Shevchenko wrote:
> On Fri, Aug 3, 2018 at 6:59 PM, Andy Shevchenko
> <andy.shevchenko@gmail.com> wrote:
>> On Fri, Aug 3, 2018 at 6:17 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>>> But then I decided to simplify it to just use dev_err().  I still have
>>> the old version.  When I submit v3 of the patchset, which would you prefer?
>> JFYI: git log --no-merges --grep 'NULL device \*'
> Example:
>
> commit b4ba97e76763c4e582e3af1079e220e93b1b0d76
> Author: Chris Wilson <chris@chris-wilson.co.uk>
> Date:   Fri Aug 19 08:37:50 2016 +0100
>
>    drm: Avoid calling dev_printk(.dev = NULL)
>

Point taken.A  I'll go with pool_err() on the next round.
