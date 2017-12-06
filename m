Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E65E6B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 16:21:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n187so3615042pfn.10
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 13:21:28 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d2si2576697plh.541.2017.12.06.13.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 13:21:26 -0800 (PST)
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
References: <20171204021411.4786-1-jhubbard@nvidia.com>
 <20171204105549.GA31332@rei>
 <efb6eae4-7f30-42c3-0efe-0ab5fbf0fdb4@nvidia.com>
 <20171205070510.aojohhvixijk3i27@dhcp22.suse.cz>
 <2cff594a-b481-269d-dd91-ff2cc2f4100a@nvidia.com>
 <20171206100118.GA13979@rei>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <deb952d9-82bc-e737-8060-8fe7e70f44a1@nvidia.com>
Date: Wed, 6 Dec 2017 13:21:25 -0800
MIME-Version: 1.0
In-Reply-To: <20171206100118.GA13979@rei>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>

On 12/06/2017 02:01 AM, Cyril Hrubis wrote:
> Hi!
>> (It does seem unfortunate that the man page cannot help the programmer
>> actually write correct code here. He or she is forced to read the kernel
>> implementation, in order to figure out the true alignment rules. I was
>> hoping we could avoid that.)
> 
> It would be nice if we had this information exported somehere so that we
> do not have to rely on per-architecture ifdefs.
> 
> What about adding MapAligment or something similar to the /proc/meminfo?
> 

What's the use case you envision for that? I don't see how that would be
better than using SHMLBA, which is available at compiler time. Because 
unless someone expects to be able to run an app that was compiled for 
Arch X, on Arch Y (surely that's not requirement here?), I don't see how
the run-time check is any better.

Or maybe you're thinking that since the SHMLBA cannot be put in the man
pages, we could instead provide MapAlignment as sort of a different
way to document the requirement?

--
thanks,
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
