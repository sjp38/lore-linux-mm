Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74B746B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 04:39:23 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j22so3491264qtj.15
        for <linux-mm@kvack.org>; Wed, 31 May 2017 01:39:23 -0700 (PDT)
Received: from mail-qt0-x230.google.com (mail-qt0-x230.google.com. [2607:f8b0:400d:c0d::230])
        by mx.google.com with ESMTPS id f2si15789695qtd.210.2017.05.31.01.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 01:39:22 -0700 (PDT)
Received: by mail-qt0-x230.google.com with SMTP id v27so6718818qtg.2
        for <linux-mm@kvack.org>; Wed, 31 May 2017 01:39:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170531140904.5c956b9a@firefly.ozlabs.ibm.com>
References: <20170524172024.30810-1-jglisse@redhat.com> <20170524172024.30810-15-jglisse@redhat.com>
 <20170531140904.5c956b9a@firefly.ozlabs.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 31 May 2017 18:39:21 +1000
Message-ID: <CAKTCnznqst35DRGWHW5ryOevV8fU=8MTev9=mFUwQCWrU-CO=A@mail.gmail.com>
Subject: Re: [HMM 14/15] mm/migrate: support un-addressable ZONE_DEVICE page
 in migration v2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>

On Wed, May 31, 2017 at 2:09 PM, Balbir Singh <bsingharora@gmail.com> wrote=
:
> On Wed, 24 May 2017 13:20:23 -0400
> J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:
>
>> Allow to unmap and restore special swap entry of un-addressable
>> ZONE_DEVICE memory.
>>
>> Changed since v1:
>>   - s/device unaddressable/device private/
>>
>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> ---

Sorry! Please ignore my comments, this is only for un-addressable memory


Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
