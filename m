Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id AD6266B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 14:11:52 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so26023pbc.12
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:11:52 -0700 (PDT)
Received: by mail-lb0-f171.google.com with SMTP id u14so173606lbd.2
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:11:48 -0700 (PDT)
MIME-Version: 1.0
From: Ning Qu <quning@google.com>
Date: Wed, 25 Sep 2013 11:11:06 -0700
Message-ID: <CACQD4-4Snvq=L2Wxw8auaRyQe=Axau9GegS+CdGvT9jycaTf-A@mail.gmail.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Got you. THanks!

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Wed, Sep 25, 2013 at 2:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> Hi, Kirill,
>>
>> Seems you dropped one patch in v5, is that intentional? Just wondering .=
..
>>
>>   thp, mm: handle tail pages in page_cache_get_speculative()
>
> It's not needed anymore, since we don't have tail pages in radix tree.
>
> --
>  Kirill A. Shutemov
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
