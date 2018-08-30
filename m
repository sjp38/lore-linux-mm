Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 642526B51F5
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:14:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id w19-v6so4829716pfa.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:14:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p15-v6sor1982414pfk.92.2018.08.30.07.14.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 07:14:50 -0700 (PDT)
Date: Fri, 31 Aug 2018 00:14:46 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 3/7] mm/hmm: fix race between hmm_mirror_unregister() and
 mmu_notifier callback
Message-ID: <20180830141446.GB28695@350D>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-4-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180824192549.30844-4-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org

On Fri, Aug 24, 2018 at 03:25:45PM -0400, jglisse@redhat.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> In hmm_mirror_unregister(), mm->hmm is set to NULL and then
> mmu_notifier_unregister_no_release() is called. That creates a small
> window where mmu_notifier can call mmu_notifier_ops with mm->hmm equal
> to NULL. Fix this by first unregistering mmu notifier callbacks and
> then setting mm->hmm to NULL.
> 
> Similarly in hmm_register(), set mm->hmm before registering mmu_notifier
> callbacks so callback functions always see mm->hmm set.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: stable@vger.kernel.org

Reviewed-by: Balbir Singh <bsingharora@gmail.com>
