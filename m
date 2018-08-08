Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52A546B0010
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 09:18:51 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w14-v6so2233446qkw.2
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 06:18:51 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id i8-v6si3445827qkm.41.2018.08.08.06.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 06:18:50 -0700 (PDT)
Subject: Re: [PATCH v3 08/10] dmapool: improve accuracy of debug statistics
References: <cbe2fb30-54b3-663e-4e30-448353723b8f@cybernetics.com>
 <CAHp75Vcnf8m0zW+8Y8=fTE+F_bDjmaQpR0s2qiTdkOzqe2+fBA@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <99f91604-f7ea-aaaa-fc15-3c1264603d0b@cybernetics.com>
Date: Wed, 8 Aug 2018 09:18:48 -0400
MIME-Version: 1.0
In-Reply-To: <CAHp75Vcnf8m0zW+8Y8=fTE+F_bDjmaQpR0s2qiTdkOzqe2+fBA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

On 08/08/2018 05:54 AM, Andy Shevchenko wrote:
> On Tue, Aug 7, 2018 at 7:49 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
>> The "total number of blocks in pool" debug statistic currently does not
>> take the boundary value into account, so it diverges from the "total
>> number of blocks in use" statistic when a boundary is in effect.  Add a
>> calculation for the number of blocks per allocation that takes the
>> boundary into account, and use it to replace the inaccurate calculation.
>
>> +       retval->blks_per_alloc =
>> +               (allocation / boundary) * (boundary / size) +
>> +               (allocation % boundary) / size;
> If boundary is guaranteed to be power of 2, this can avoid cost
> divisions (though it's a slow path anyway).
>
At this point in the function, boundary is guaranteed to be either a
power of 2 or equal to allocation, which might not be a power of 2.A  Not
worth special-casing a slow path.
