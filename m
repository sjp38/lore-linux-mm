Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 828456B0296
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:48:50 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v2-v6so3999761wrr.10
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:48:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3-v6sor990334wmb.35.2018.07.25.04.48.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 04:48:49 -0700 (PDT)
Date: Wed, 25 Jul 2018 13:48:47 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 3/3] mm: move mirrored memory specific code outside of
 memmap_init_zone
Message-ID: <20180725114847.GA16691@techadventures.net>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-4-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724235520.10200-4-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, Jul 24, 2018 at 07:55:20PM -0400, Pavel Tatashin wrote:
> memmap_init_zone, is getting complex, because it is called from different
> contexts: hotplug, and during boot, and also because it must handle some
> architecture quirks. One of them is mirroed memory.
> 
> Move the code that decides whether to skip mirrored memory outside of
> memmap_init_zone, into a separate function.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Hi Pavel,

this looks good to me.
Over the past days I thought if it would make sense to have two
memmap_init_zone functions, one for hotplug and another one for early init,
so we could get rid of the altmap stuff in the early init, and also the 
MEMMAP_EARLY/HOTPLUG context thing could be gone.

But I think that they would just share too much of the code, so I do not think
it is worth.

I am working to do that for free_area_init_core, let us see what I come up with.

Anyway, this looks nicer, so thanks for that.
I also gave it a try, and early init and memhotplug code seems to work fine.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
