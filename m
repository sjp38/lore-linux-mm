Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6976B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:44:20 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z13-v6so317381wrt.19
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:44:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l204-v6sor260577wma.26.2018.07.17.04.44.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 04:44:19 -0700 (PDT)
Date: Tue, 17 Jul 2018 13:44:17 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v6 5/5] mm/sparse: delete old sparse_init and enable new
 one
Message-ID: <20180717114417.GA24361@techadventures.net>
References: <20180716174447.14529-1-pasha.tatashin@oracle.com>
 <20180716174447.14529-6-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716174447.14529-6-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Mon, Jul 16, 2018 at 01:44:47PM -0400, Pavel Tatashin wrote:
> Rename new_sparse_init() to sparse_init() which enables it.  Delete old
> sparse_init() and all the code that became obsolete with.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Tested-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

I tested it also with a powerpc vm.
And as I said, the code becomes much more clean now.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks
-- 
Oscar Salvador
SUSE L3
