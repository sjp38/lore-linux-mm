Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 604106B0006
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 16:28:44 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id f22so26078648qkm.11
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 13:28:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i35sor8872314qtb.21.2018.11.12.13.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 13:28:42 -0800 (PST)
Date: Mon, 12 Nov 2018 21:28:39 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory
 functions
Message-ID: <20181112212839.ut4owdqfuibzuhvz@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-3-osalvador@techadventures.net>
 <CAPcyv4jM-EJCmOwFkPqXhtgR54UueNtHjfCUbnnJqFLmgj7Jvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jM-EJCmOwFkPqXhtgR54UueNtHjfCUbnnJqFLmgj7Jvw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, rppt@linux.vnet.ibm.com, malat@debian.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Jonathan.Cameron@huawei.com, "Rafael J. Wysocki" <rafael@kernel.org>, David Hildenbrand <david@redhat.com>, Dave Jiang <dave.jiang@intel.com>, Linux MM <linux-mm@kvack.org>, alexander.h.duyck@linux.intel.com, osalvador@suse.de

> 
> This collides with the refactoring of hmm, to be done in terms of
> devm_memremap_pages(). I'd rather not introduce another common
> function *beneath* hmm and devm_memremap_pages() and rather make
> devm_memremap_pages() the common function.
> 
> I plan to resubmit that cleanup after Plumbers. So, unless I'm
> misunderstanding some other benefit a nak from me on this patch as it
> stands currently.
> 

Ok, Dan, I will wait for your new refactoring series before continuing
reviewing this series.

Thank you,
Pasha
