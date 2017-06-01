Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E05536B02FD
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 18:35:23 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 34so13628499qto.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 15:35:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f49si21221013qta.61.2017.06.01.15.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 15:35:22 -0700 (PDT)
Date: Thu, 1 Jun 2017 18:35:18 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170601223518.GA2780@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
 <20170524172024.30810-13-jglisse@redhat.com>
 <20170531135954.1d67ca31@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170531135954.1d67ca31@firefly.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Wed, May 31, 2017 at 01:59:54PM +1000, Balbir Singh wrote:
> On Wed, 24 May 2017 13:20:21 -0400
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > This patch add a new memory migration helpers, which migrate memory
> > backing a range of virtual address of a process to different memory
> > (which can be allocated through special allocator). It differs from
> > numa migration by working on a range of virtual address and thus by
> > doing migration in chunk that can be large enough to use DMA engine
> > or special copy offloading engine.
> > 
> > Expected users are any one with heterogeneous memory where different
> > memory have different characteristics (latency, bandwidth, ...). As
> > an example IBM platform with CAPI bus can make use of this feature
> > to migrate between regular memory and CAPI device memory. New CPU
> > architecture with a pool of high performance memory not manage as
> > cache but presented as regular memory (while being faster and with
> > lower latency than DDR) will also be prime user of this patch.
> > 
> > Migration to private device memory will be useful for device that
> > have large pool of such like GPU, NVidia plans to use HMM for that.
> > 
> 
> It is helpful, for HMM-CDM however we would like to avoid the downsides
> of MIGRATE_SYNC_NOCOPY

What are the downside you are referring too ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
