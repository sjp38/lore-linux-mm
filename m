Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8846B02B4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 10:34:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 77so1171474wmm.13
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 07:34:10 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x24si36422423edb.128.2017.06.06.07.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Jun 2017 07:34:08 -0700 (PDT)
Date: Tue, 6 Jun 2017 10:33:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node
 counters
Message-ID: <20170606143349.GB1602@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-3-hannes@cmpxchg.org>
 <20170531091256.GA5914@osiris>
 <20170531113900.GB5914@osiris>
 <20170531171151.e4zh7ffzbl4w33gd@yury-thinkpad>
 <87mv9s2f8f.fsf@concordia.ellerman.id.au>
 <20170605183511.GA8915@cmpxchg.org>
 <87k24prb3u.fsf@concordia.ellerman.id.au>
 <87mv9lpdsr.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mv9lpdsr.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Yury Norov <ynorov@caviumnetworks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

On Tue, Jun 06, 2017 at 09:15:48PM +1000, Michael Ellerman wrote:
> But today's linux-next is OK. So I must have missed a fix when testing
> this in isolation.
> 
> commit d94b69d9a3f8139e6d5f5d03c197d8004de3905a
> Author:     Johannes Weiner <hannes@cmpxchg.org>
> AuthorDate: Tue Jun 6 09:19:50 2017 +1000
> Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> CommitDate: Tue Jun 6 09:19:50 2017 +1000
> 
>     mm: vmstat: move slab statistics from zone to node counters fix
>     
>     Unable to handle kernel paging request at virtual address 2e116007
>     pgd = c0004000
>     [2e116007] *pgd=00000000
>     Internal error: Oops: 5 [#1] SMP ARM
> 
> ...
> 
> Booted to userspace:
> 
> $ uname -a
> Linux buildroot 4.12.0-rc4-gcc-5.4.1-00130-gd94b69d9a3f8 #354 SMP Tue Jun 6 20:44:42 AEST 2017 ppc64le GNU/Linux

Thanks for verifying!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
