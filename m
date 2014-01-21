Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8B29B6B0082
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:12:53 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id 29so3020152yhl.5
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:12:53 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id v21si7681879yhm.273.2014.01.21.14.12.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 14:12:50 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id c41so1131312yho.20
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:12:49 -0800 (PST)
Date: Tue, 21 Jan 2014 14:12:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
In-Reply-To: <52caac5c.27cb440a.533d.ffffbbd2SMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <alpine.DEB.2.02.1401211411140.1666@chino.kir.corp.google.com>
References: <20130427112418.GC4441@localhost.localdomain> <0000013e5645b356-09aa6796-0a95-40f1-8ec5-6e2e3d0c434f-000000@email.amazonses.com> <20130429145711.GC1172@dhcp22.suse.cz> <20130502105637.GD4441@localhost.localdomain>
 <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com> <20130503030345.GE4441@localhost.localdomain> <0000013e6aff6f95-b8fa366e-51a5-4632-962e-1b990520f5a8-000000@email.amazonses.com> <20130503153450.GA18709@dhcp22.suse.cz>
 <0000013e6b2e06ab-a26ffcc5-a52d-4165-9be0-025ae813da00-000000@email.amazonses.com> <52bd58da.2501440a.6368.16ddSMTPIN_ADDED_BROKEN@mx.google.com> <52caac5c.27cb440a.533d.ffffbbd2SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Han Pingtian <hanpt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Mon, 6 Jan 2014, Wanpeng Li wrote:

> >Is there any progress against slub's fix?
> >
> >MemTotal:        7760960 kB
> >Slab:            7064448 kB
> >SReclaimable:     143936 kB
> >SUnreclaim:      6920512 kB
> >
> >112084  10550   9%   16.00K   3507       32   1795584K kmalloc-16384
> >2497920  48092   1%    0.50K  19515      128   1248960K kmalloc-512 
> >6058888  89363   1%    0.19K  17768      341   1137152K kmalloc-192
> >114468  13719  11%    4.58K   2082       55    532992K task_struct 
> >
> 
> This machine has 200 CPUs and 8G memory. There is an oom storm, we are
> seeing OOM even in boot process.
> 

Is this still a problem with 3.9 and later kernels?  Please try to 
reproduce it on 3.13.

If it does reproduce, could you try to pinpoint the problem with kmemleak?  
Look into Documentation/kmemleak.txt which should identify where these 
leaks are coming from with your slab allocator of choice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
