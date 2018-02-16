Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89EE26B0007
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 16:45:53 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id r5so3651876qkb.22
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:45:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor822825qkn.142.2018.02.16.13.45.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 13:45:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180216183032.GA7439@bombadil.infradead.org>
References: <1515496262-7533-1-git-send-email-wei.w.wang@intel.com>
 <1515496262-7533-2-git-send-email-wei.w.wang@intel.com> <CAHp75Ve-1-TOVJUZ4anhwkkeq-RhpSg3EmN3N0r09rj6sFrQZQ@mail.gmail.com>
 <20180216183032.GA7439@bombadil.infradead.org>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 16 Feb 2018 23:45:51 +0200
Message-ID: <CAHp75Vd_tt0bV_OqAOwc=_uWrsF2zP9pMSbxPw_AxF_s9zj-pw@mail.gmail.com>
Subject: Re: [PATCH v21 1/5] xbitmap: Introduce xbitmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, david@redhat.com, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Fri, Feb 16, 2018 at 8:30 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Feb 16, 2018 at 07:44:50PM +0200, Andy Shevchenko wrote:
>> On Tue, Jan 9, 2018 at 1:10 PM, Wei Wang <wei.w.wang@intel.com> wrote:
>> > From: Matthew Wilcox <mawilcox@microsoft.com>
>> >
>> > The eXtensible Bitmap is a sparse bitmap representation which is
>> > efficient for set bits which tend to cluster. It supports up to
>> > 'unsigned long' worth of bits.
>>
>> >  lib/xbitmap.c                            | 444 +++++++++++++++++++++++++++++++
>>
>> Please, split tests to a separate module.
>
> Hah, I just did this two days ago!  I didn't publish it yet, but I also made
> it compile both in userspace and as a kernel module.
>
> It's the top two commits here:
>
> http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2018-02-12
>

Thanks!

> Note this is a complete rewrite compared to the version presented here; it
> sits on top of the XArray and no longer has a preload interface.  It has a
> superset of the IDA functionality.

Noted.

Now, the question about test case. Why do you heavily use BUG_ON?
Isn't resulting statistics enough?

See how other lib/test_* modules do.

-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
