Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2695E6B7783
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:28:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x19-v6so5446617pfh.15
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:28:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j15-v6si4304595pgm.95.2018.09.06.00.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:28:06 -0700 (PDT)
Date: Thu, 6 Sep 2018 09:28:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 07/29] memblock: remove _virt from APIs returning
 virtual address
Message-ID: <20180906072800.GN14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
 <CABGGiswdb1x-=vqrgxZ9i2dnLdsgtXq4+5H9Y1JRd90YVMW69A@mail.gmail.com>
 <20180905172017.GA2203@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905172017.GA2203@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Rob Herring <robh@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, mingo@redhat.com, Michael Ellerman <mpe@ellerman.id.au>, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 05-09-18 20:20:18, Mike Rapoport wrote:
> On Wed, Sep 05, 2018 at 12:04:36PM -0500, Rob Herring wrote:
> > On Wed, Sep 5, 2018 at 11:00 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > >
> > > The conversion is done using
> > >
> > > sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
> > >         $(git grep -l memblock_virt_alloc)
> > 
> > What's the reason to do this? It seems like a lot of churn even if a
> > mechanical change.
> 
> I felt that memblock_virt_alloc_ is too long for a prefix, e.g:
> memblock_virt_alloc_node_nopanic, memblock_virt_alloc_low_nopanic.
> 
> And for consistency I've changed the memblock_virt_alloc as well.

I would keep the current API unless the name is terribly misleading or
it can be improved a lot. Neither seems to be the case here. So I would
rather stick with the status quo.
-- 
Michal Hocko
SUSE Labs
