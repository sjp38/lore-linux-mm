Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 81FF56B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 23:32:52 -0400 (EDT)
Received: by yhcb70 with SMTP id b70so10304344yhc.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 20:32:52 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id ih3si16195286vdb.44.2015.04.24.20.32.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 20:32:49 -0700 (PDT)
Message-ID: <1429932759.16571.31.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 25 Apr 2015 13:32:39 +1000
In-Reply-To: <553AFCC1.5070502@redhat.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <553AFCC1.5070502@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 2015-04-24 at 22:32 -0400, Rik van Riel wrote:
> >       The result would be that the kernel would allocate only
> migratable
> >       pages within the CCAD device's memory, and even then only if
> >       memory was otherwise exhausted.
> 
> Does it make sense to allocate the device's page tables in memory
> belonging to the device?
> 
> Is this a necessary thing with some devices? Jerome's HMM comes
> to mind...

In our case, the device's MMU shares the host page tables (which is why
we can't use HMM, ie we can't have a page with different permissions on
CPU vs. device which HMM does).

However the device has a pretty fast path to system memory, the best
thing we can do is pin the workload to the same chip the device is
connected to so those page tables arent' too far away.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
