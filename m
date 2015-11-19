Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3666C6B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 19:23:40 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so62888553pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:23:40 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id zk6si7800910pbc.252.2015.11.18.16.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 16:23:39 -0800 (PST)
Received: by pacej9 with SMTP id ej9so60818184pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:23:39 -0800 (PST)
Date: Wed, 18 Nov 2015 16:23:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional
 kfree()/vfree()
In-Reply-To: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1511181623240.1381@chino.kir.corp.google.com>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, linux-acpi@vger.kernel.org, drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, codalist@coda.cs.cmu.edu, linux-mtd@lists.infradead.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org

On Mon, 9 Nov 2015, Tetsuo Handa wrote:

> There are many locations that do
> 
>   if (memory_was_allocated_by_vmalloc)
>     vfree(ptr);
>   else
>     kfree(ptr);
> 
> but kvfree() can handle both kmalloc()ed memory and vmalloc()ed memory
> using is_vmalloc_addr(). Unless callers have special reasons, we can
> replace this branch with kvfree(). Please check and reply if you found
> problems.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Russell King <linux@arm.linux.org.uk> # arm
> Cc: <linux-acpi@vger.kernel.org> # apei
> Cc: <drbd-user@lists.linbit.com> # drbd
> Cc: <linux-kernel@vger.kernel.org> # mspec
> Cc: <dri-devel@lists.freedesktop.org> # drm
> Cc: Oleg Drokin <oleg.drokin@intel.com> # lustre
> Cc: Andreas Dilger <andreas.dilger@intel.com> # lustre
> Cc: <codalist@coda.cs.cmu.edu> # coda
> Cc: <linux-mtd@lists.infradead.org> # jffs2
> Cc: Jan Kara <jack@suse.com> # udf
> Cc: <linux-fsdevel@vger.kernel.org> # xattr
> Cc: <linux-mm@kvack.org> # ipc + mm
> Cc: <netdev@vger.kernel.org> # ipv4

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
