Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15D6C6B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:32:44 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j130so5577614qke.13
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:32:44 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x48si2166678qtc.355.2018.04.13.09.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 09:32:43 -0700 (PDT)
Subject: Re: [PATCH RFC 7/8] mm: allow to control onlining/offlining of memory
 by a driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413133334.3612-1-david@redhat.com>
 <20180413155943.GY17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <92ff9057-7f1e-d9b7-610e-0a7022b8da01@redhat.com>
Date: Fri, 13 Apr 2018 18:32:39 +0200
MIME-Version: 1.0
In-Reply-To: <20180413155943.GY17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>, "moderated list:XEN HYPERVISOR INTERFACE" <xen-devel@lists.xenproject.org>

On 13.04.2018 17:59, Michal Hocko wrote:
> On Fri 13-04-18 15:33:28, David Hildenbrand wrote:
>> Some devices (esp. paravirtualized) might want to control
>> - when to online/offline a memory block
>> - how to online memory (MOVABLE/NORMAL)
>> - in which granularity to online/offline memory
>>
>> So let's add a new flag "driver_managed" and disallow to change the
>> state by user space. Device onlining/offlining will still work, however
>> the memory will not be actually onlined/offlined. That has to be handled
>> by the device driver that owns the memory.
> 
> Is there any reason to create the memblock sysfs interface to this
> memory at all? ZONE_DEVICE mem hotplug users currently do not do that
> and manage the memory themselves. It seems you want to achieve the same
> thing, no?
> 

Yes, I think so, namely kdump. We have to retrigger kexec() whenever a
memory block is added/removed. udev events are sent for that reason when
a memory block is created/deleted. And I think this is not done for
ZONE_DEVICE devices, or am I wrong?

-- 

Thanks,

David / dhildenb
