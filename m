Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B99C6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 07:59:24 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id h12so3969064wre.12
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 04:59:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f142si3588617wmf.73.2017.12.07.04.59.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 04:59:22 -0800 (PST)
Date: Thu, 7 Dec 2017 13:58:05 +0100
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171207125805.GA1210@rei.lan>
References: <20171204021411.4786-1-jhubbard@nvidia.com>
 <20171204105549.GA31332@rei>
 <efb6eae4-7f30-42c3-0efe-0ab5fbf0fdb4@nvidia.com>
 <20171205070510.aojohhvixijk3i27@dhcp22.suse.cz>
 <2cff594a-b481-269d-dd91-ff2cc2f4100a@nvidia.com>
 <20171206100118.GA13979@rei>
 <deb952d9-82bc-e737-8060-8fe7e70f44a1@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <deb952d9-82bc-e737-8060-8fe7e70f44a1@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>

Hi!
> >> (It does seem unfortunate that the man page cannot help the programmer
> >> actually write correct code here. He or she is forced to read the kernel
> >> implementation, in order to figure out the true alignment rules. I was
> >> hoping we could avoid that.)
> > 
> > It would be nice if we had this information exported somehere so that we
> > do not have to rely on per-architecture ifdefs.
> > 
> > What about adding MapAligment or something similar to the /proc/meminfo?
> > 
> 
> What's the use case you envision for that? I don't see how that would be
> better than using SHMLBA, which is available at compiler time. Because 
> unless someone expects to be able to run an app that was compiled for 
> Arch X, on Arch Y (surely that's not requirement here?), I don't see how
> the run-time check is any better.

I guess that some kind of compile time constant in uapi headers will do
as well, I'm really open to any solution that would expose this constant
as some kind of official API.

There is one problem with using SHMLBA, there are more than one libc
implementations and at least two of them (bionic and klibc) does not
implement the SysV IPC at all. I know that the chances that you are
writing a program that requires MAP_FIXED, is compiled against
alternative libc, and expected to run on less common architectures are
pretty slim. On the other hand I do not see a reason why this cannot be
done properly, this is just about exporting one simple constant to
userspace after all.

> Or maybe you're thinking that since the SHMLBA cannot be put in the man
> pages, we could instead provide MapAlignment as sort of a different
> way to document the requirement?

This is my intention as well.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
