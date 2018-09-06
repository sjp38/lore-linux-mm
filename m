Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9F3D6B78F0
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:21:39 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l14-v6so12820375oii.9
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:21:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e4-v6si3607657oih.240.2018.09.06.06.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 06:21:38 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86DEjDP008383
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 09:21:38 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mb2y9p56q-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:21:37 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 14:21:35 +0100
Date: Thu, 6 Sep 2018 16:21:26 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906091538.GN14951@dhcp22.suse.cz>
 <46ae5e64-7b1a-afab-bfef-d00183a7ef76@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46ae5e64-7b1a-afab-bfef-d00183a7ef76@microsoft.com>
Message-Id: <20180906132126.GK27492@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Sep 06, 2018 at 01:04:47PM +0000, Pasha Tatashin wrote:
> 
> 
> On 9/6/18 5:15 AM, Michal Hocko wrote:
> > On Wed 05-09-18 18:59:15, Mike Rapoport wrote:
> > [...]
> >>  325 files changed, 846 insertions(+), 2478 deletions(-)
> >>  delete mode 100644 include/linux/bootmem.h
> >>  delete mode 100644 mm/bootmem.c
> >>  delete mode 100644 mm/nobootmem.c
> > 
> > This is really impressive! Thanks a lot for working on this. I wish we
> > could simplify the memblock API as well. There are just too many public
> > functions with subtly different semantic and barely any useful
> > documentation.
> > 
> > But even this is a great step forward!
> 
> This is a great simplification of boot process. Thank you Mike!
> 
> I agree, with Michal in the future, once nobootmem kernel stabalizes
> after this effort, we should start simplifying memblock allocator API:
> it won't be as big effort as this one, as I think, that can be done in
> incremental phases, but it will help to make early boot much more stable
> and uniform across arches.

It's not only about the memblock APIs. Every arch has its own way of memory
detection and initialization, all this should be revisited at some point.
But yes, apart from the memblock APIs update which will be quite
disruptive, the arches memory initialization can be updated incrementally.
 
> Thank you,
> Pavel

-- 
Sincerely yours,
Mike.
