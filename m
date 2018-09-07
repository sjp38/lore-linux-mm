Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6A26B7F60
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 13:05:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x24-v6so5052177edm.13
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 10:05:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f22-v6sor8883422edd.5.2018.09.07.10.04.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 10:04:59 -0700 (PDT)
Date: Fri, 7 Sep 2018 17:04:51 +0000
From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH V5 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
Message-ID: <20180907170451.GA5771@darwi-kernel>
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com

Hi!

On Sat, Sep 08, 2018 at 02:03:02AM +0800, Zhang Yi wrote:
[...]
>
> V1:
> https://lkml.org/lkml/2018/7/4/91
>
> V2:
> https://lkml.org/lkml/2018/7/10/135
>
> V3:
> https://lkml.org/lkml/2018/8/9/17
>
> V4:
> https://lkml.org/lkml/2018/8/22/17
>

Can we please avoid referencing "lkml.org"?

It's just an unreliable broken website. [1][2] Much more important
though is that its URLs _hide_ the Message-Id field; running the
threat of losing the e-mail reference forever at some point in the
future.

>From Documentation/process/submitting-patches.rst:

    If the patch follows from a mailing list discussion, give a
    URL to the mailing list archive; use the https://lkml.kernel.org/
    redirector with a ``Message-Id``, to ensure that the links
    cannot become stale.

So the V1 link above should've been either:

    https://lore.kernel.org/lkml/cover.1530716899.git.yi.z.zhang@linux.intel.com

or:

    https://lkml.kernel.org/r/cover.1530716899.git.yi.z.zhang@linux.intel.com

and so on..

Thanks,

[1] https://www.theregister.co.uk/2018/01/14/linux_kernel_mailing_list_archives_will_return_soon
[2] The threading interface is also broken and in a lot of cases
    does not show all messages in a thread

--
Darwi
http://darwish.chasingpointers.com
