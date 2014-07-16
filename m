Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 843DC6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:10:10 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so996653pde.12
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 03:10:10 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id vt4si14116421pab.110.2014.07.16.03.10.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 03:10:09 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1034400pad.25
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 03:10:09 -0700 (PDT)
Date: Wed, 16 Jul 2014 03:08:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 5/7] selftests: add memfd/sealing page-pinning tests
In-Reply-To: <1402655819-14325-6-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.LSU.2.11.1407160307460.1775@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com> <1402655819-14325-6-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

On Fri, 13 Jun 2014, David Herrmann wrote:

> Setting SEAL_WRITE is not possible if there're pending GUP users. This
> commit adds selftests for memfd+sealing that use FUSE to create pending
> page-references. FUSE is very helpful here in that it allows us to delay
> direct-IO operations for an arbitrary amount of time. This way, we can
> force the kernel to pin pages and then run our normal selftests.
> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

I had a number of problems in getting this working (on openSUSE 13.1):
rpm told me I had fuse installed, yet I had to download and install
the tarball to get header files needed; then "make fuse_mnt" told me
to add -D_FILE_OFFSET_BITS=64 to the compile flags; after which I
got "undefined reference to `fuse_main_real'"; but then I tried
"make run_fuse" as root, and it seemed to sort these issues out
for itself, aside from "./run_fuse_test.sh: Permission denied" -
which was within my bounds of comprehension unlike the rest!

No complaint, thanks for providing the test (though I didn't check
the source to convince myself that "DONE" has done what's claimed):
some rainy day someone can get the Makefile working more smoothly,
no need to delay the patchset for this.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
