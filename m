Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3C46B0313
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 08:30:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p17so7572831wmd.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:30:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k32si272253wrc.311.2017.07.26.05.30.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 05:30:46 -0700 (PDT)
Date: Wed, 26 Jul 2017 14:30:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/5] mm, memory_hotplug: allocate memmap from the
 added memory range for sparse-vmemmap
Message-ID: <20170726123040.GO2981@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726083333.17754-4-mhocko@kernel.org>
 <20170726114539.GG3218@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726114539.GG3218@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dan Williams <dan.j.williams@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Wed 26-07-17 13:45:39, Heiko Carstens wrote:
[...]
> In general I do like your idea, however if I understand your patches
> correctly we might have an ordering problem on s390: it is not possible to
> access hot-added memory on s390 before it is online (MEM_GOING_ONLINE
> succeeded).

Could you point me to the code please? I cannot seem to find the
notifier which implements that.

> On MEM_GOING_ONLINE we ask the hypervisor to back the potential available
> hot-added memory region with physical pages. Accessing those ranges before
> that will result in an exception.

Can we make the range which backs the memmap range available? E.g from
s390 specific __vmemmap_populate path?
 
> However with your approach the memory is still allocated when add_memory()
> is being called, correct? That wouldn't be a change to the current
> behaviour; except for the ordering problem outlined above.

Could you be more specific please? I do not change when the memmap is
allocated.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
