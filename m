Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F41D6B0974
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:04:13 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so2989147edd.11
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:04:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u11-v6si6311573ejf.108.2018.11.16.05.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:04:11 -0800 (PST)
Message-ID: <1542373433.3020.19.camel@suse.de>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory
 functions
From: osalvador <osalvador@suse.de>
Date: Fri, 16 Nov 2018 14:03:53 +0100
In-Reply-To: <CAPcyv4jM-EJCmOwFkPqXhtgR54UueNtHjfCUbnnJqFLmgj7Jvw@mail.gmail.com>
References: <20181015153034.32203-1-osalvador@techadventures.net>
	 <20181015153034.32203-3-osalvador@techadventures.net>
	 <CAPcyv4jM-EJCmOwFkPqXhtgR54UueNtHjfCUbnnJqFLmgj7Jvw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, rppt@linux.vnet.ibm.com, malat@debian.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Jonathan.Cameron@huawei.com, "Rafael J. Wysocki" <rafael@kernel.org>, David Hildenbrand <david@redhat.com>, Dave Jiang <dave.jiang@intel.com>, Linux MM <linux-mm@kvack.org>, alexander.h.duyck@linux.intel.com

> This collides with the refactoring of hmm, to be done in terms of
> devm_memremap_pages(). I'd rather not introduce another common
> function *beneath* hmm and devm_memremap_pages() and rather make
> devm_memremap_pages() the common function.

Hi Dan,

That is true.
Previous version of this patchet was based on yours (hmm-refactor),
but then I decided to not base it here due to lack of feedback.
But if devm_memremap_pages() is going to be the main/common function,
I am totally fine to put the memory-hotplug specific there.

> I plan to resubmit that cleanup after Plumbers. So, unless I'm
> misunderstanding some other benefit a nak from me on this patch as it
> stands currently.

Great, then I will wait for your new patchset, and then I will base
this one on that.

Thanks
Oscar Salvador
