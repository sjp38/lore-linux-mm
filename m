Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8197D6B0285
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:15:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a102-v6so12641680qka.0
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:15:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p14-v6si1557996qvi.108.2018.10.12.11.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:15:48 -0700 (PDT)
Date: Fri, 12 Oct 2018 14:15:45 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/7] HMM updates, improvements and fixes
Message-ID: <20181012181545.GG6593@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180824192549.30844-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, Aug 24, 2018 at 03:25:42PM -0400, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Few fixes that only affect HMM users. Improve the synchronization call
> back so that we match was other mmu_notifier listener do and add proper
> support to the new blockable flags in the process.
> 
> For curious folks here are branches to leverage HMM in various existing
> device drivers:
> 
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau-v01
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-radeon-v00
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-intel-v00
> 
> More to come (amd gpu, Mellanox, ...)
> 
> I expect more of the preparatory work for nouveau will be merge in 4.20
> (like we have been doing since 4.16) and i will wait until this patchset
> is upstream before pushing the patches that actualy make use of HMM (to
> avoid complex tree inter-dependency).
> 

Andrew do you want me to repost this on top of lastest mmotm ?
All conflict should be pretty trivial to fix.

Cheers,
Jerome
