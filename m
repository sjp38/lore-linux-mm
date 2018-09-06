Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id D59546B78A9
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:43:35 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c18-v6so12730056oiy.3
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:43:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c201-v6si3275169oib.248.2018.09.06.05.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:43:35 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86Cfx9o044584
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 08:43:34 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mb3fftv4b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 08:43:33 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 13:43:31 +0100
Date: Thu, 6 Sep 2018 15:43:21 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 07/29] memblock: remove _virt from APIs returning
 virtual address
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
 <CABGGiswdb1x-=vqrgxZ9i2dnLdsgtXq4+5H9Y1JRd90YVMW69A@mail.gmail.com>
 <20180905172017.GA2203@rapoport-lnx>
 <20180906072800.GN14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906072800.GN14951@dhcp22.suse.cz>
Message-Id: <20180906124321.GD27492@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rob Herring <robh@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, mingo@redhat.com, Michael Ellerman <mpe@ellerman.id.au>, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Sep 06, 2018 at 09:28:00AM +0200, Michal Hocko wrote:
> On Wed 05-09-18 20:20:18, Mike Rapoport wrote:
> > On Wed, Sep 05, 2018 at 12:04:36PM -0500, Rob Herring wrote:
> > > On Wed, Sep 5, 2018 at 11:00 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > > >
> > > > The conversion is done using
> > > >
> > > > sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
> > > >         $(git grep -l memblock_virt_alloc)
> > > 
> > > What's the reason to do this? It seems like a lot of churn even if a
> > > mechanical change.
> > 
> > I felt that memblock_virt_alloc_ is too long for a prefix, e.g:
> > memblock_virt_alloc_node_nopanic, memblock_virt_alloc_low_nopanic.
> > 
> > And for consistency I've changed the memblock_virt_alloc as well.
> 
> I would keep the current API unless the name is terribly misleading or
> it can be improved a lot. Neither seems to be the case here. So I would
> rather stick with the status quo.

I'm ok with the memblock_virt_alloc by itself, but having 'virt' in
'memblock_virt_alloc_try_nid_nopanic' and 'memblock_virt_alloc_low_nopanic'
reduces code readability in my opinion.

Besides, from what I've seen, many users of memblock_phys_alloc can be
converted to the virtual variant and then we can just have memblock_alloc
everywhere in the end.

Currently there are ~70 users of memblock_virt_alloc*, but with the
bootmem -> memblock conversion we'll be adding ~140 more.

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
