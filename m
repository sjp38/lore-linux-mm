Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A895E6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:46:36 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id cc10so6129962wib.4
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:46:36 -0800 (PST)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id bo12si491965wib.66.2013.12.03.00.46.35
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:46:35 -0800 (PST)
Date: Tue, 3 Dec 2013 10:46:35 +0200 (EET)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: Slab BUG with DEBUG_* options
In-Reply-To: <00000142b4b122b4-377a8c1e-32e1-401e-a9c0-caa7e8ade31c-000000@email.amazonses.com>
Message-ID: <alpine.SOC.1.00.1312031045510.3485@math.ut.ee>
References: <alpine.SOC.1.00.1311300125490.6363@math.ut.ee> <alpine.DEB.2.02.1311301428390.18027@chino.kir.corp.google.com> <00000142b4b122b4-377a8c1e-32e1-401e-a9c0-caa7e8ade31c-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> Does this patch from 3.13 fix it?
> 
> commit c6f58d9b362b45c52afebe4342c9137d0dabe47f
> Author: Christoph Lameter <cl@linux.com>
> Date:   Thu Nov 7 16:29:15 2013 +0000
> 
>     slub: Handle NULL parameter in kmem_cache_flags

I do not think so - it is for slub but this machine uses slab.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
