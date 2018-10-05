Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57F626B0010
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 03:15:32 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id a77-v6so10399303wrc.16
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 00:15:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y199-v6sor698186wmd.8.2018.10.05.00.15.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 00:15:31 -0700 (PDT)
Date: Fri, 5 Oct 2018 09:15:29 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 1/6] mm/memory_hotplug: make remove_memory() take the
 device_hotplug_lock
Message-ID: <20181005071529.GC27754@techadventures.net>
References: <20180927092554.13567-1-david@redhat.com>
 <20180927092554.13567-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927092554.13567-2-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

On Thu, Sep 27, 2018 at 11:25:49AM +0200, David Hildenbrand wrote:
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
 
Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
