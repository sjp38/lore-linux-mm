Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE7B6B0498
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 05:02:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y23so1785277wra.16
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 02:02:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 48si1958584edz.287.2017.12.06.02.02.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 02:02:33 -0800 (PST)
Date: Wed, 6 Dec 2017 11:01:18 +0100
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171206100118.GA13979@rei>
References: <20171204021411.4786-1-jhubbard@nvidia.com>
 <20171204105549.GA31332@rei>
 <efb6eae4-7f30-42c3-0efe-0ab5fbf0fdb4@nvidia.com>
 <20171205070510.aojohhvixijk3i27@dhcp22.suse.cz>
 <2cff594a-b481-269d-dd91-ff2cc2f4100a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2cff594a-b481-269d-dd91-ff2cc2f4100a@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>

Hi!
> (It does seem unfortunate that the man page cannot help the programmer
> actually write correct code here. He or she is forced to read the kernel
> implementation, in order to figure out the true alignment rules. I was
> hoping we could avoid that.)

It would be nice if we had this information exported somehere so that we
do not have to rely on per-architecture ifdefs.

What about adding MapAligment or something similar to the /proc/meminfo?

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
