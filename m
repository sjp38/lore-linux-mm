Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3AEF6B0994
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:06:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id k58so4532292eda.20
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:06:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11-v6si2442361edj.131.2018.11.16.05.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:06:44 -0800 (PST)
Message-ID: <1542373588.3020.22.camel@suse.de>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory
 functions
From: osalvador <osalvador@suse.de>
Date: Fri, 16 Nov 2018 14:06:28 +0100
In-Reply-To: <20181112212839.ut4owdqfuibzuhvz@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
	 <20181015153034.32203-3-osalvador@techadventures.net>
	 <CAPcyv4jM-EJCmOwFkPqXhtgR54UueNtHjfCUbnnJqFLmgj7Jvw@mail.gmail.com>
	 <20181112212839.ut4owdqfuibzuhvz@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>, Dan Williams <dan.j.williams@intel.com>
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, rppt@linux.vnet.ibm.com, malat@debian.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Jonathan.Cameron@huawei.com, "Rafael J. Wysocki" <rafael@kernel.org>, David Hildenbrand <david@redhat.com>, Dave Jiang <dave.jiang@intel.com>, Linux MM <linux-mm@kvack.org>, alexander.h.duyck@linux.intel.com

On Mon, 2018-11-12 at 21:28 +0000, Pavel Tatashin wrote:
> > 
> > This collides with the refactoring of hmm, to be done in terms of
> > devm_memremap_pages(). I'd rather not introduce another common
> > function *beneath* hmm and devm_memremap_pages() and rather make
> > devm_memremap_pages() the common function.
> > 
> > I plan to resubmit that cleanup after Plumbers. So, unless I'm
> > misunderstanding some other benefit a nak from me on this patch as
> > it
> > stands currently.
> > 
> 
> Ok, Dan, I will wait for your new refactoring series before
> continuing
> reviewing this series.

Hi Pavel,

thanks for reviewing the other patches.
You could still check patch4 and patch5, as they are not strictly
related to this one.
(Not asking for your Reviewed-by, but I would still like you to check
them)
I could use your eyes there if you have time ;-)

Thanks
Oscar Salvador
