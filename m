Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id BE8386B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 22:32:52 -0400 (EDT)
Received: by widdi4 with SMTP id di4so40984967wid.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 19:32:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k1si1846233wif.77.2015.04.24.19.32.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 19:32:51 -0700 (PDT)
Message-ID: <553AFCC1.5070502@redhat.com>
Date: Fri, 24 Apr 2015 22:32:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150421214445.GA29093@linux.vnet.ibm.com>
In-Reply-To: <20150421214445.GA29093@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/21/2015 05:44 PM, Paul E. McKenney wrote:

> AUTONUMA
> 
> 	The Linux kernel's autonuma facility supports migrating both
> 	memory and processes to promote NUMA memory locality.  It was
> 	accepted into 3.13 and is available in RHEL 7.0 and SLES 12.
> 	It is enabled by the Kconfig variable CONFIG_NUMA_BALANCING.
> 
> 	This approach uses a kernel thread "knuma_scand" that periodically
> 	marks pages inaccessible.  The page-fault handler notes any
> 	mismatches between the NUMA node that the process is running on
> 	and the NUMA node on which the page resides.

Minor nit: marking pages inaccessible is done from task_work
nowadays, there no longer is a kernel thread.

> 	The result would be that the kernel would allocate only migratable
> 	pages within the CCAD device's memory, and even then only if
> 	memory was otherwise exhausted.

Does it make sense to allocate the device's page tables in memory
belonging to the device?

Is this a necessary thing with some devices? Jerome's HMM comes
to mind...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
