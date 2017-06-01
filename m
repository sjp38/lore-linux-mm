Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 008616B0311
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 18:35:55 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k9so19252990qkh.10
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 15:35:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u25si20533220qtu.127.2017.06.01.15.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 15:35:54 -0700 (PDT)
Date: Thu, 1 Jun 2017 18:35:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 02/15] mm/hmm: heterogeneous memory management (HMM for
 short) v4
Message-ID: <20170601223549.GB2780@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
 <20170524172024.30810-3-jglisse@redhat.com>
 <20170531121024.4e14f91a@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170531121024.4e14f91a@firefly.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Wed, May 31, 2017 at 12:10:24PM +1000, Balbir Singh wrote:
> On Wed, 24 May 2017 13:20:11 -0400
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > HMM provides 3 separate types of functionality:
> >     - Mirroring: synchronize CPU page table and device page table
> >     - Device memory: allocating struct page for device memory
> >     - Migration: migrating regular memory to device memory
> > 
> > This patch introduces some common helpers and definitions to all of
> > those 3 functionality.
> > 
> > Changed since v3:
> >   - Unconditionaly build hmm.c for static keys
> > Changed since v2:
> >   - s/device unaddressable/device private
> > Changed since v1:
> >   - Kconfig logic (depend on x86-64 and use ARCH_HAS pattern)
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> > Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> > Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> > ---
> 
> It would be nice to explain a bit of how hmm_pfn_t bits work with pfn
> and find out what we need from an arch to support HMM.
> 

This is only needed for HMM_MIRROR feature so you do not care about it
for powerpc

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
