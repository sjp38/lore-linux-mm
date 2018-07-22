Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8718C6B0003
	for <linux-mm@kvack.org>; Sun, 22 Jul 2018 19:34:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5-v6so128864edr.19
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 16:34:40 -0700 (PDT)
Received: from mail.nethype.de (mail.nethype.de. [5.9.56.24])
        by mx.google.com with ESMTPS id w44-v6si5939584edb.165.2018.07.22.16.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 22 Jul 2018 16:34:39 -0700 (PDT)
Date: Mon, 23 Jul 2018 01:34:37 +0200
From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180722233437.34e5ckq5pp24gsod@schmorp.de>
References: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
 <20180710123222.GK14284@dhcp22.suse.cz>
 <20180717234549.4ng2expfkgaranuq@schmorp.de>
 <20180718083808.GR7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180718083808.GR7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Wed, Jul 18, 2018 at 10:38:08AM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> > http://data.plan9.de/kvm_oom.txt
> 
> That is something to bring up with kvm guys. Order-6 pages are
> considered costly and success of the allocation is by no means
> guaranteed. Unike for orders smaller than 4 they do not trigger the oom
> killer though.

So 4 is the magic barrier, good to know. In any case, as I said, it's just
an example of various allocations that fail unexpectedly after 4.4, and it's
by no means just nvidia.

> vmalloc fallback would be a good alternative. Unfortunatelly I am not
> able to find which allocation is that. What does faddr2line kvm_dev_ioctl_create_vm+0x40
> say?

I suspect I can't run this for an installed kernel without sources/object
files? In this case a precompiled kernel from ubuntu mainline-ppa.
Running faddr2line kvm.ko ... just gives me:

   kvm_dev_ioctl_create_vm+0x40/0x5d1:
   kvm_dev_ioctl_create_vm at ??:?

-- 
                The choice of a       Deliantra, the free code+content MORPG
      -----==-     _GNU_              http://www.deliantra.net
      ----==-- _       generation
      ---==---(_)__  __ ____  __      Marc Lehmann
      --==---/ / _ \/ // /\ \/ /      schmorp@schmorp.de
      -=====/_/_//_/\_,_/ /_/\_\
