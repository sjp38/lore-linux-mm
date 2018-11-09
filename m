Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 798196B0724
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 16:15:25 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id y83so6060885qka.7
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 13:15:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor9739868qtp.68.2018.11.09.13.15.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 13:15:24 -0800 (PST)
Date: Fri, 9 Nov 2018 16:15:21 -0500
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
Message-ID: <20181109211521.5ospn33pp552k2xv@xakep.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, daniel.m.jordan@oracle.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On 18-11-05 13:19:25, Alexander Duyck wrote:
> This patchset is essentially a refactor of the page initialization logic
> that is meant to provide for better code reuse while providing a
> significant improvement in deferred page initialization performance.
> 
> In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> memory per node I have seen the following. In the case of regular memory
> initialization the deferred init time was decreased from 3.75s to 1.06s on
> average. For the persistent memory the initialization time dropped from
> 24.17s to 19.12s on average. This amounts to a 253% improvement for the
> deferred memory initialization performance, and a 26% improvement in the
> persistent memory initialization performance.

Hi Alex,

Please try to run your persistent memory init experiment with Daniel's
patches:

https://lore.kernel.org/lkml/20181105165558.11698-1-daniel.m.jordan@oracle.com/

The performance should improve by much more than 26%.

Overall, your works looks good, but it needs to be considered how easy it will be
to merge with ktask. I will try to complete the review today.

Thank you,
Pasha
