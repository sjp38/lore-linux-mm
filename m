Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEF76B0257
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 22:49:00 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so141990698pac.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 19:48:59 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id fl1si8834339pab.174.2015.09.08.19.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 19:48:59 -0700 (PDT)
Message-ID: <1441766934.7854.10.camel@ellerman.id.au>
Subject: Re: [PATCH 03/12] userfaultfd: selftests: vm: pick up sanitized
 kernel headers
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 09 Sep 2015 12:48:54 +1000
In-Reply-To: <1441745010-14314-4-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
	 <1441745010-14314-4-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David
 Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On Tue, 2015-09-08 at 22:43 +0200, Andrea Arcangeli wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> Add the usr/include subdirectory of the top-level tree to the include
> path, and make sure to include headers without relative paths to make sure
> the sanitized headers get picked up.  Otherwise the compiler will not be
> able to find the linux/compiler.h header included by the non- sanitized
> include/uapi/linux/userfaultfd.h.
> 
> While at it, make sure to only hardcode the syscall numbers on x86 and
> PowerPC if they haven't been properly picked up from the headers.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> Cc: Shuah Khan <shuahkh@osg.samsung.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  tools/testing/selftests/vm/Makefile      | 2 +-
>  tools/testing/selftests/vm/userfaultfd.c | 4 +++-
>  2 files changed, 4 insertions(+), 2 deletions(-)

This is not perfect, but better than what's there, so:

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
