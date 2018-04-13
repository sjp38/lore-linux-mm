Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6775A6B0006
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 11:59:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v11so5396156wri.13
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:59:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t14si7899179edi.108.2018.04.13.08.59.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 08:59:47 -0700 (PDT)
Date: Fri, 13 Apr 2018 17:59:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 7/8] mm: allow to control onlining/offlining of
 memory by a driver
Message-ID: <20180413155943.GY17484@dhcp22.suse.cz>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413133334.3612-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413133334.3612-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>, "moderated list:XEN HYPERVISOR INTERFACE" <xen-devel@lists.xenproject.org>

On Fri 13-04-18 15:33:28, David Hildenbrand wrote:
> Some devices (esp. paravirtualized) might want to control
> - when to online/offline a memory block
> - how to online memory (MOVABLE/NORMAL)
> - in which granularity to online/offline memory
> 
> So let's add a new flag "driver_managed" and disallow to change the
> state by user space. Device onlining/offlining will still work, however
> the memory will not be actually onlined/offlined. That has to be handled
> by the device driver that owns the memory.

Is there any reason to create the memblock sysfs interface to this
memory at all? ZONE_DEVICE mem hotplug users currently do not do that
and manage the memory themselves. It seems you want to achieve the same
thing, no?
-- 
Michal Hocko
SUSE Labs
