Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44B2D2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 20:57:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m54so63041260qtb.9
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 17:57:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p38si9064615qtp.290.2017.06.30.17.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 17:57:54 -0700 (PDT)
Date: Fri, 30 Jun 2017 20:57:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170701005749.GA7232@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Jun 30, 2017 at 04:19:25PM -0700, Evgeny Baskakov wrote:
> Hi Jerome,
> 
> It seems that the kernel can pass 0 in src_pfns for pages that it cannot
> migrate (i.e. the kernel knows that they cannot migrate prior to calling
> alloc_and_copy).
> 
> So, a zero in src_pfns can mean either "the page is not allocated yet" or
> "the page cannot migrate".
> 
> Can migrate_vma set the MIGRATE_PFN_MIGRATE flag for not allocated pages? On
> the driver side it is difficult to differentiate between the cases.

So this is what is happening in v24. For thing that can not be migrated you
get 0 and for things that are not allocated you get MIGRATE_PFN_MIGRATE like
the updated comments in migrate.h explain.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
