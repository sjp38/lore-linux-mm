Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB3D6B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:22:02 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so3302412pde.29
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 05:22:02 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id sf3si1405029pac.165.2014.03.27.05.22.01
        for <linux-mm@kvack.org>;
        Thu, 27 Mar 2014 05:22:01 -0700 (PDT)
Date: Thu, 27 Mar 2014 12:21:39 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 1/3] kmemleak: allow freeing internal objects after
 kmemleak was disabled
Message-ID: <20140327122139.GH20298@arm.com>
References: <5326750E.1000004@huawei.com>
 <F7314A69-24BE-42B9-8E99-8F9292B397C4@arm.com>
 <53338CFE.3060705@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53338CFE.3060705@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Mar 27, 2014 at 02:29:18AM +0000, Li Zefan wrote:
> On 2014/3/22 7:37, Catalin Marinas wrote:
> > On 17 Mar 2014, at 04:07, Li Zefan <lizefan@huawei.com> wrote:
> >> Currently if kmemleak is disabled, the kmemleak objects can never be freed,
> >> no matter if it's disabled by a user or due to fatal errors.
> >>
> >> Those objects can be a big waste of memory.
> >>
> >>  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> >> 1200264 1197433  99%    0.30K  46164       26    369312K kmemleak_object
> >>
> >> With this patch, internal objects will be freed immediately if kmemleak is
> >> disabled explicitly by a user. If it's disabled due to a kmemleak error,
> >> The user will be informed, and then he/she can reclaim memory with:
> >>
> >> 	# echo off > /sys/kernel/debug/kmemleak
> >>
> >> v2: use "off" handler instead of "clear" handler to do this, suggested
> >>    by Catalin.
> > 
> > I think there was a slight misunderstanding. My point was about "echo
> > scan=offa?? before a??echo offa??, they can just be squashed into the
> > same action of the latter.
> 
> I'm not sure if I understand correctly, so you want the "off" handler to
> stop the scan thread but it will never free kmemleak objects until the 
> user explicitly trigger the "clear" action, right?

Yes. That's just in case someone wants to stop kmemleak but still
investigate some previously reported leaks.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
