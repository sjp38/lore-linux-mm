Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1A58E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 01:53:38 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t26-v6so559804pfh.0
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 22:53:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r14-v6si17877529pfa.44.2018.09.17.22.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 22:53:32 -0700 (PDT)
Date: Tue, 18 Sep 2018 22:31:49 +0800
From: Yi Zhang <yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH V5 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
Message-ID: <20180918143148.GB70800@tiger-server>
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
 <20180907170451.GA5771@darwi-kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180907170451.GA5771@darwi-kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de, linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com

Thanks Darwi's remind, Will follow that next time.

Thanks.
Yi

On 2018-09-07 at 17:04:51 +0000, Ahmed S. Darwish wrote:
> Hi!
> 
> On Sat, Sep 08, 2018 at 02:03:02AM +0800, Zhang Yi wrote:
> [...]
> >
> > V1:
> > https://lkml.org/lkml/2018/7/4/91
> >
> > V2:
> > https://lkml.org/lkml/2018/7/10/135
> >
> > V3:
> > https://lkml.org/lkml/2018/8/9/17
> >
> > V4:
> > https://lkml.org/lkml/2018/8/22/17
> >
> 
> Can we please avoid referencing "lkml.org"?
> 
> It's just an unreliable broken website. [1][2] Much more important
> though is that its URLs _hide_ the Message-Id field; running the
> threat of losing the e-mail reference forever at some point in the
> future.
> 
> From Documentation/process/submitting-patches.rst:
> 
>     If the patch follows from a mailing list discussion, give a
>     URL to the mailing list archive; use the https://lkml.kernel.org/
>     redirector with a ``Message-Id``, to ensure that the links
>     cannot become stale.
> 
> So the V1 link above should've been either:
> 
>     https://lore.kernel.org/lkml/cover.1530716899.git.yi.z.zhang@linux.intel.com
> 
> or:
> 
>     https://lkml.kernel.org/r/cover.1530716899.git.yi.z.zhang@linux.intel.com
> 
> and so on..
> 
> Thanks,
> 
> [1] https://www.theregister.co.uk/2018/01/14/linux_kernel_mailing_list_archives_will_return_soon
> [2] The threading interface is also broken and in a lot of cases
>     does not show all messages in a thread
> 
> --
> Darwi
> http://darwish.chasingpointers.com
