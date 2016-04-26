Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B286E6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:03:21 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k200so14099636lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:03:21 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id r14si15357515lfe.140.2016.04.26.07.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:03:20 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id m101so2471689lfi.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:03:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJu=L5-CjPWj4+Vi0QKPLvyCM32mBz_x_y_6fo-Q2gy_gE8OKA@mail.gmail.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
 <571565F0.9070203@linaro.org> <20160419165024.GB24312@redhat.com>
 <CAJu=L59T4KsEORSOza7TBdnbWtypKgyuGUOZpzvMTENo4rmSqg@mail.gmail.com>
 <CACzj_yVnuirXiOt7EiH+SKj27Rk8DOq5hoz8aBD6r1WROFNGdQ@mail.gmail.com> <CAJu=L5-CjPWj4+Vi0QKPLvyCM32mBz_x_y_6fo-Q2gy_gE8OKA@mail.gmail.com>
From: Wincy Van <fanwenyi0529@gmail.com>
Date: Tue, 26 Apr 2016 22:02:59 +0800
Message-ID: <CACzj_yW6gqrEaZABQKkJTooULCu5TvhgtdYaP0qUW5Hd=jTZJQ@mail.gmail.com>
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Shi, Yang" <yang.shi@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Apr 25, 2016 at 9:30 PM, Andres Lagar-Cavilla
<andreslc@google.com> wrote:
>>
>> We are using kvm + tmpfs to do qemu live upgrading, how does google
>> use this memory model ?
>> I think our pupose to use tmpfs may be the same.
>
> Nothing our of the ordinary. Guest memory is an mmap of a tmpfs fd.
> Huge tmpfs gives us naturally a great guest performance boost.
> MAP_SHARED, and having guest memory persist any one given process, are
> what drives us to use tmpfs.
>

OK. We are also using mmap.

Besides google's kvm userspace(as I know it is not qemu), google have another
userspace tool need to access guest memory, so that google use tmpfs?

If so, what function does that another userspace do?

Thanks,
Wincy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
