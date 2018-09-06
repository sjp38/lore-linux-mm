Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8CA6B78CF
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:16:47 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q11-v6so12842208oih.15
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:16:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e133-v6si3272197oib.118.2018.09.06.06.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 06:16:46 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86DEVxB077965
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 09:16:46 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mb2a57h17-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:16:45 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 14:16:43 +0100
Date: Thu, 6 Sep 2018 16:16:34 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906091538.GN14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906091538.GN14951@dhcp22.suse.cz>
Message-Id: <20180906131634.GJ27492@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 06, 2018 at 11:15:38AM +0200, Michal Hocko wrote:
> On Wed 05-09-18 18:59:15, Mike Rapoport wrote:
> [...]
> >  325 files changed, 846 insertions(+), 2478 deletions(-)
> >  delete mode 100644 include/linux/bootmem.h
> >  delete mode 100644 mm/bootmem.c
> >  delete mode 100644 mm/nobootmem.c
> 
> This is really impressive! Thanks a lot for working on this. I wish we
> could simplify the memblock API as well. There are just too many public
> functions with subtly different semantic and barely any useful
> documentation.

There are also many functions with exactly the same semantic :)

Cleaning up the memblock API would be the next step.
 
> But even this is a great step forward!
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
