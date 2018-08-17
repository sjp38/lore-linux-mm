Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCF0D6B093D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 13:02:44 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 2-v6so5141977plc.11
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 10:02:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y8-v6si2637193plr.136.2018.08.17.10.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 10:02:43 -0700 (PDT)
Date: Fri, 17 Aug 2018 19:02:39 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH RFC 1/2] drivers/base: export
 lock_device_hotplug/unlock_device_hotplug
Message-ID: <20180817170239.GF24945@kroah.com>
References: <20180817075901.4608-1-david@redhat.com>
 <20180817075901.4608-2-david@redhat.com>
 <20180817084146.GB14725@kroah.com>
 <5a5d73e9-e4aa-ffed-a2e3-8aef64e61923@redhat.com>
 <CAJZ5v0gkYV8o2Eq+EcGT=OP1tQGPGVVe3n9VGD6z7KAVVqhv9w@mail.gmail.com>
 <42df9062-f647-3ad6-5a07-be2b99531119@redhat.com>
 <20180817100604.GA18164@kroah.com>
 <4ac624be-d2d6-5975-821f-b20a475781dc@redhat.com>
 <20180817112850.GB3565@osiris>
 <ecc08303-96ee-76ad-fba4-0425413afa5a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ecc08303-96ee-76ad-fba4-0425413afa5a@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, "Rafael J. Wysocki" <rafael@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, linux-s390@vger.kernel.org, sthemmin@microsoft.com, Pavel Tatashin <pasha.tatashin@oracle.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, Len Brown <lenb@kernel.org>, haiyangz@microsoft.com, Dan Williams <dan.j.williams@intel.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, osalvador@suse.de, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, Aug 17, 2018 at 01:56:35PM +0200, David Hildenbrand wrote:
> E.g. When adding the memory block devices, we know that there won't be a
> driver to attach to (as there are no drivers for the "memory" subsystem)
> - the bus_probe_device() function that takes the device_lock() could
> pretty much be avoided for that case. But burying such special cases
> down in core driver code definitely won't make locking related to memory
> hotplug easier.

You don't have to have a driver for a device if you don't want to, or
you can just have a default one for all memory devices if you somehow
need it.  No reason to not do this if it makes things easier for you.

thanks,

greg k-h
