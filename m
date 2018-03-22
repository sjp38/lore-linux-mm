Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAAE86B000A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 21:59:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 139so3676649pfw.7
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:59:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o6-v6sor2427774plh.68.2018.03.21.18.59.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 18:59:42 -0700 (PDT)
Date: Wed, 21 Mar 2018 19:00:14 -0700
From: Nicolin Chen <nicoleotsuka@gmail.com>
Subject: Re: mm/hmm: a simple question regarding devm_request_mem_region()
Message-ID: <20180322020013.GA26480@Asurada-Nvidia>
References: <20180321222357.GA31089@Asurada-Nvidia>
 <20180321225632.GI3214@redhat.com>
 <20180322002352.GA12673@Asurada-Nvidia>
 <20180322003253.GL3214@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180322003253.GL3214@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 21, 2018 at 08:32:54PM -0400, Jerome Glisse wrote:

> > I am testing with drivers/char/hmm_dmirror.c from your git repository.
> > 
> > The addr I got (before "- size") is actually 0x7fffffffff, so equally
> > (1 << 40).
> > 
> > So from your reply, it seems to me that HMM is supposed to request a
> > region like it.
> 
> The dummy driver by default test the private memory, i had patches to
> make it test public memory too somewhere in a branch. So yes this is
> expected from the dummy driver. HMM here is trying to get a region that
> will not collide with any known existing resources. Idealy we would
> like a platform/arch function for that but it is hard to justify it
> nor is there a safe way to find such thing either from arch/platform
> specific code (there isn't for x86 at least).
> 
> For real device driver of pcie devices, the advice is to use the pci
> bar region of the device. This way we know for sure we do not collide
> with anything (ie use hmm_devmem_add_resource() not hmm_devmem_add()
> but this need some code change for res->desc).

I see. Thank you!
