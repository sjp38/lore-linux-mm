Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A9FE46B0253
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 11:22:37 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id v188so60335414wme.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 08:22:37 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id g72si9482870wmi.124.2016.04.07.08.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 08:22:36 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id 191so95533148wmq.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 08:22:36 -0700 (PDT)
Date: Thu, 7 Apr 2016 17:22:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: Re: PG_reserved and compound pages
Message-ID: <20160407152234.GE32755@dhcp22.suse.cz>
References: <4482994.u2S3pScRyb@noys2>
 <3877205.TjDYue2aah@noys2>
 <20160406153343.GJ24272@dhcp22.suse.cz>
 <20567553.kUaGmfXpqH@noys2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20567553.kUaGmfXpqH@noys2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 07-04-16 15:45:02, Frank Mehnert wrote:
> On Wednesday 06 April 2016 17:33:43 Michal Hocko wrote:
[...]
> > Do you map your pages to the userspace? If yes then vma with VM_IO or
> > VM_PFNMAP should keep any attempt away from those pages.
> 
> Yes, such memory objects are also mapped to userland. Do you think that
> VM_IO or VM_PFNMAP would guard against NUMA page migration?

Both auto numa and manual numa migration checks vma_migratable and that
excludes both VM flags.

> Because when
> NUMA page migration was introduced (I believe with Linux 3.8) I tested
> both flags and saw that they didn't prevent the migration on such VM
> areas. Maybe this changed in the meantime, do you have more information
> about that?

I haven't checked the history much but vma_migratable should be there
for quite some time. Maybe it wasn't used in the past. Dunno

> The drawback of at least VM_IO is that such memory is not part of a core
> dump.

that seems to be correct as per vma_dump_size

> Actually currently we use vm_insert_page() for userland mapping
> and mark the VM areas as
> 
>   VM_DONTEXPAND | VM_DONTDUMP

but that means that it won't end up in the dump either. Or am I missing
your point.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
