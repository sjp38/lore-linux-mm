Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C73FE6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 09:30:03 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id n83so270893038qkn.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:30:03 -0700 (PDT)
Received: from mail-yw0-x22c.google.com (mail-yw0-x22c.google.com. [2607:f8b0:4002:c05::22c])
        by mx.google.com with ESMTPS id v199si5958291ywe.178.2016.04.25.06.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 06:30:02 -0700 (PDT)
Received: by mail-yw0-x22c.google.com with SMTP id o66so210038210ywc.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:30:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACzj_yVnuirXiOt7EiH+SKj27Rk8DOq5hoz8aBD6r1WROFNGdQ@mail.gmail.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
	<571565F0.9070203@linaro.org>
	<20160419165024.GB24312@redhat.com>
	<CAJu=L59T4KsEORSOza7TBdnbWtypKgyuGUOZpzvMTENo4rmSqg@mail.gmail.com>
	<CACzj_yVnuirXiOt7EiH+SKj27Rk8DOq5hoz8aBD6r1WROFNGdQ@mail.gmail.com>
Date: Mon, 25 Apr 2016 06:30:01 -0700
Message-ID: <CAJu=L5-CjPWj4+Vi0QKPLvyCM32mBz_x_y_6fo-Q2gy_gE8OKA@mail.gmail.com>
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wincy Van <fanwenyi0529@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Shi, Yang" <yang.shi@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sat, Apr 23, 2016 at 10:46 PM, Wincy Van <fanwenyi0529@gmail.com> wrote:
> On Wed, Apr 20, 2016 at 1:07 AM, Andres Lagar-Cavilla
> <andreslc@google.com> wrote:
>> Andrea, we provide the, ahem, adjustments to
>> transparent_hugepage_adjust. Rest assured we aggressively use mmu
>> notifiers with no further changes required.
>>
>> As in: zero changes have been required in the lifetime (years) of
>> kvm+huge tmpfs at Google, other than mod'ing
>> transparent_hugepage_adjust.
>
> We are using kvm + tmpfs to do qemu live upgrading, how does google
> use this memory model ?
> I think our pupose to use tmpfs may be the same.

Nothing our of the ordinary. Guest memory is an mmap of a tmpfs fd.
Huge tmpfs gives us naturally a great guest performance boost.
MAP_SHARED, and having guest memory persist any one given process, are
what drives us to use tmpfs.

Andres
>
> And huge tmpfs is a really good improvement for that.
>
>>
>> As noted by Paolo, the additions to transparent_hugepage_adjust could
>> be lifted outside of kvm (into shmem.c? maybe) for any consumer of
>> huge tmpfs with mmu notifiers.
>>
>
> Thanks,
> Wincy



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
