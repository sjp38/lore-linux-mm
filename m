Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43A956B0008
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 13:53:01 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z126so25640278qka.10
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:53:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e38sor11274144qtk.19.2018.11.12.10.53.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 10:53:00 -0800 (PST)
Date: Mon, 12 Nov 2018 18:52:56 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH 1/5] mm/memory_hotplug: Add nid parameter to
 arch_remove_memory
Message-ID: <20181112185256.dbintostrvyoddf5@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-2-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015153034.32203-2-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>

On 18-10-15 17:30:30, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> This patch is only a preparation for the following-up patches.
> The idea of passing the nid is that will allow us to get rid
> of the zone parameter in the patches that follow
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
