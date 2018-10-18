Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07D116B0008
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 02:57:26 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id w193-v6so3264307wmf.8
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 23:57:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20-v6sor2928082wme.3.2018.10.17.23.57.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 23:57:24 -0700 (PDT)
Date: Thu, 18 Oct 2018 08:57:22 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Create add/del_device_memory
 functions
Message-ID: <20181018065722.GA29999@techadventures.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-3-osalvador@techadventures.net>
 <d0a12eb5-3824-8d25-75f8-3e62f1e81994@redhat.com>
 <20181017093331.GA25724@techadventures.net>
 <883d3ab7-b2df-9b9a-7681-1019ce3b9e18@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <883d3ab7-b2df-9b9a-7681-1019ce3b9e18@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

On Wed, Oct 17, 2018 at 11:45:50AM +0200, David Hildenbrand wrote:
> Here you go ;)
> 
> Reviewed-by: David Hildenbrand <david@redhat.com>

thanks!

> I'm planning to look into the other patches as well, but I'll be busy
> with traveling and KVM forum the next 1.5 weeks.

No need to hurry, this can wait.

-- 
Oscar Salvador
SUSE L3
