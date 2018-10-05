Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4898C6B0269
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 03:16:25 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id y199-v6so420665wmc.6
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 00:16:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h130-v6sor655308wmf.28.2018.10.05.00.16.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 00:16:23 -0700 (PDT)
Date: Fri, 5 Oct 2018 09:16:22 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 2/6] mm/memory_hotplug: make add_memory() take the
 device_hotplug_lock
Message-ID: <20181005071622.GD27754@techadventures.net>
References: <20180927092554.13567-1-david@redhat.com>
 <20180927092554.13567-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927092554.13567-3-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>

On Thu, Sep 27, 2018 at 11:25:50AM +0200, David Hildenbrand wrote:
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
