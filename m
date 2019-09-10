Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F829C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:42:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E35E521479
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:42:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mdlhWpzQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E35E521479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 605EB6B0003; Tue, 10 Sep 2019 10:42:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58FB36B0006; Tue, 10 Sep 2019 10:42:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4561F6B0007; Tue, 10 Sep 2019 10:42:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id 233FA6B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:42:56 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C857D824376B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:42:55 +0000 (UTC)
X-FDA: 75919277910.08.scent13_53bbcfbaea963
X-HE-Tag: scent13_53bbcfbaea963
X-Filterd-Recvd-Size: 5745
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:42:55 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id n197so38066321iod.9
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:42:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qwfqdrsthj6wGMKbVfq9KS+2D4+bl2wd+HAoXgrqGpM=;
        b=mdlhWpzQsILASMQ7+1ikwT0fUSiwI9Yno2A8k95yLHD6P9eV0S05kOW5Jv6prsMvSt
         iBXlVLmgNneBJJPewyY1Iz+eUwtz//m6IWYeMweTFXG1suDqKgsSJ2xCT/kZ1HcGuX4Y
         n5DFuajmtetj/LpA2LEgEC9oiE4MlkG9fH5vD+eWjaUxrS6bT4PmDA2aOayknXG3RXII
         9e0AvcNoE4ZxbCtIxiI/lT91HGh0dhQFb9BVLzxS7z4Bakuzjqvda8OJvgMc4cNBYsKq
         JywENk314egMFnOMmeOVAlHQzPFr5FrWB11JMPxvnyAvp/9VaOr3lB+4BYVwvWI0USRT
         DKkA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=qwfqdrsthj6wGMKbVfq9KS+2D4+bl2wd+HAoXgrqGpM=;
        b=uXivBvYOkN0/LOJiya1i1QIPCzYCt6dJ2A6YjOw9UcmsE4kfdWhQbIHYVTPLMJA4Aq
         tIshRSYBgHlTIyRaP5+stroRtYq+apR40rrtBZ5oKMlXlM0XJJmzqWWkhgYIbdPe9din
         Wb0v43kCfOjGOjAeyfqEKotKwC/3dm3d3Q1B/rE5ZQNkLAWyQYizAOfnO5fP4c5CNH1/
         MZyaT3dvSf0yQDzzuEZnRof4sfN03Pj9WmIKFIuExWY9gCRxaGtDscOgZahbsxmcGgNr
         2BHTUEqJ9QvgZB8R7H5hkbrORzB0lJ2a1vTQFYiwh3yypuHL/0eNaXAkK26JbBX2KTro
         AE7Q==
X-Gm-Message-State: APjAAAXTkgy5Li3lvZ/8P0NjMZzk9wtVWuMSWqSmO/i+6ZTOZNiZYYeG
	S0g+VxZJzDbKTSiWBMqxKQ0xGvobv7U2xULKTyY=
X-Google-Smtp-Source: APXvYqw25PAt3681VzSp2aKtn4HION8cnSVVgIaDxDN4t5As0qF4aUf02XL+Yw/GC74k1NJX1qc/ljlh1hZcV/Ap7TM=
X-Received: by 2002:a02:9f16:: with SMTP id z22mr31770205jal.83.1568126574433;
 Tue, 10 Sep 2019 07:42:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190907172225.10910.34302.stgit@localhost.localdomain> <20190910124209.GY2063@dhcp22.suse.cz>
In-Reply-To: <20190910124209.GY2063@dhcp22.suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 10 Sep 2019 07:42:43 -0700
Message-ID: <CAKgT0Udr6nYQFTRzxLbXk41SiJ-pcT_bmN1j1YR4deCwdTOaUQ@mail.gmail.com>
Subject: Re: [PATCH v9 0/8] stg mail -e --version=v9 \
To: Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, will@kernel.org, 
	linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Pankaj Gupta <pagupta@redhat.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitesh Narayan Lal <nitesh@redhat.com>, 
	Rik van Riel <riel@surriel.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 5:42 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> I wanted to review "mm: Introduce Reported pages" just realize that I
> have no clue on what is going on so returned to the cover and it didn't
> really help much. I am completely unfamiliar with virtio so please bear
> with me.
>
> On Sat 07-09-19 10:25:03, Alexander Duyck wrote:
> [...]
> > This series provides an asynchronous means of reporting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as unused page reporting
> >
> > The functionality for this is fairly simple. When enabled it will allocate
> > statistics to track the number of reported pages in a given free area.
> > When the number of free pages exceeds this value plus a high water value,
> > currently 32, it will begin performing page reporting which consists of
> > pulling pages off of free list and placing them into a scatter list. The
> > scatterlist is then given to the page reporting device and it will perform
> > the required action to make the pages "reported", in the case of
> > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > and as such they are forced out of the guest. After this they are placed
> > back on the free list,
>
> And here I am reallly lost because "forced out of the guest" makes me
> feel that those pages are no longer usable by the guest. So how come you
> can add them back to the free list. I suspect understanding this part
> will allow me to understand why we have to mark those pages and prevent
> merging.

Basically as the paragraph above mentions "forced out of the guest"
really is just the hypervisor calling MADV_DONTNEED on the page in
question. So the behavior is the same as any userspace application
that calls MADV_DONTNEED where the contents are no longer accessible
from userspace and attempting to access them will result in a fault
and the page being populated with a zero fill on-demand page, or a
copy of the file contents if the memory is file backed.

