Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23D496B026C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:57:58 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v7-v6so326731wrn.17
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:57:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t12-v6sor399322wrr.15.2018.07.17.04.57.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 04:57:56 -0700 (PDT)
Date: Tue, 17 Jul 2018 13:57:55 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v6 2/5] mm/sparse: use the new sparse buffer functions in
 non-vmemmap
Message-ID: <20180717115755.GC24361@techadventures.net>
References: <20180716174447.14529-1-pasha.tatashin@oracle.com>
 <20180716174447.14529-3-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716174447.14529-3-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Mon, Jul 16, 2018 at 01:44:44PM -0400, Pavel Tatashin wrote:
> non-vmemmap sparse also allocated large contiguous chunk of memory, and if
> fails falls back to smaller allocations.  Use the same functions to
> allocate buffer as the vmemmap-sparse
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
