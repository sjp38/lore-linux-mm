Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 296AC6B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 08:55:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l1-v6so397391edi.11
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:55:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d40-v6si3151612ede.253.2018.07.23.05.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 05:55:55 -0700 (PDT)
Date: Mon, 23 Jul 2018 14:55:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180723125554.GE31229@dhcp22.suse.cz>
References: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
 <20180710123222.GK14284@dhcp22.suse.cz>
 <20180717234549.4ng2expfkgaranuq@schmorp.de>
 <20180718083808.GR7193@dhcp22.suse.cz>
 <20180722233437.34e5ckq5pp24gsod@schmorp.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180722233437.34e5ckq5pp24gsod@schmorp.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Lehmann <schmorp@schmorp.de>
Cc: linux-mm@kvack.org

On Mon 23-07-18 01:34:37, Marc Lehmann wrote:
> On Wed, Jul 18, 2018 at 10:38:08AM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> > > http://data.plan9.de/kvm_oom.txt
> > 
> > That is something to bring up with kvm guys. Order-6 pages are
> > considered costly and success of the allocation is by no means
> > guaranteed. Unike for orders smaller than 4 they do not trigger the oom
> > killer though.
> 
> So 4 is the magic barrier, good to know.

Yeah, scientifically proven. Or something along those lines.

> In any case, as I said, it's just
> an example of various allocations that fail unexpectedly after 4.4, and it's
> by no means just nvidia.

Large allocation failures shouldn't be directly related to the OOM
changes at the time. There were many compaction fixes/enhancements
introduced at the time and later which should help those though.

Having more examples should help us to work with specific subsystems
on a more appropriate fix. Depending on large order allocations has
always been suboptimal if not outright wrong.

> 
> > vmalloc fallback would be a good alternative. Unfortunatelly I am not
> > able to find which allocation is that. What does faddr2line kvm_dev_ioctl_create_vm+0x40
> > say?
> 
> I suspect I can't run this for an installed kernel without sources/object
> files? In this case a precompiled kernel from ubuntu mainline-ppa.
> Running faddr2line kvm.ko ... just gives me:
> 
>    kvm_dev_ioctl_create_vm+0x40/0x5d1:
>    kvm_dev_ioctl_create_vm at ??:?

You need a vmlinux with debuginfo compiled IIRC.
-- 
Michal Hocko
SUSE Labs
