Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CFEB66B0005
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 01:46:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so26762043wme.0
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 22:46:48 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id c8si8861631lbb.93.2016.04.23.22.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Apr 2016 22:46:47 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id y84so3465907lfc.3
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 22:46:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJu=L59T4KsEORSOza7TBdnbWtypKgyuGUOZpzvMTENo4rmSqg@mail.gmail.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
 <571565F0.9070203@linaro.org> <20160419165024.GB24312@redhat.com> <CAJu=L59T4KsEORSOza7TBdnbWtypKgyuGUOZpzvMTENo4rmSqg@mail.gmail.com>
From: Wincy Van <fanwenyi0529@gmail.com>
Date: Sun, 24 Apr 2016 13:46:27 +0800
Message-ID: <CACzj_yVnuirXiOt7EiH+SKj27Rk8DOq5hoz8aBD6r1WROFNGdQ@mail.gmail.com>
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Shi, Yang" <yang.shi@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Ning Qu <quning@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, Apr 20, 2016 at 1:07 AM, Andres Lagar-Cavilla
<andreslc@google.com> wrote:
> Andrea, we provide the, ahem, adjustments to
> transparent_hugepage_adjust. Rest assured we aggressively use mmu
> notifiers with no further changes required.
>
> As in: zero changes have been required in the lifetime (years) of
> kvm+huge tmpfs at Google, other than mod'ing
> transparent_hugepage_adjust.

We are using kvm + tmpfs to do qemu live upgrading, how does google
use this memory model ?
I think our pupose to use tmpfs may be the same.

And huge tmpfs is a really good improvement for that.

>
> As noted by Paolo, the additions to transparent_hugepage_adjust could
> be lifted outside of kvm (into shmem.c? maybe) for any consumer of
> huge tmpfs with mmu notifiers.
>

Thanks,
Wincy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
