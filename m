Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE966B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:44:52 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id z64so3129884qka.23
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:44:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d190sor166532qka.138.2018.02.16.09.44.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 09:44:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1515496262-7533-2-git-send-email-wei.w.wang@intel.com>
References: <1515496262-7533-1-git-send-email-wei.w.wang@intel.com> <1515496262-7533-2-git-send-email-wei.w.wang@intel.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 16 Feb 2018 19:44:50 +0200
Message-ID: <CAHp75Ve-1-TOVJUZ4anhwkkeq-RhpSg3EmN3N0r09rj6sFrQZQ@mail.gmail.com>
Subject: Re: [PATCH v21 1/5] xbitmap: Introduce xbitmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, david@redhat.com, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, Paolo Bonzini <pbonzini@redhat.com>, Matthew Wilcox <willy@infradead.org>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Tue, Jan 9, 2018 at 1:10 PM, Wei Wang <wei.w.wang@intel.com> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> The eXtensible Bitmap is a sparse bitmap representation which is
> efficient for set bits which tend to cluster. It supports up to
> 'unsigned long' worth of bits.

>  lib/xbitmap.c                            | 444 +++++++++++++++++++++++++++++++

Please, split tests to a separate module.

-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
