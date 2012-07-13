Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 8AD896B005A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 18:33:36 -0400 (EDT)
Received: by qabg27 with SMTP id g27so691208qab.14
        for <linux-mm@kvack.org>; Fri, 13 Jul 2012 15:33:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120713131514.86ab4df4.akpm@linux-foundation.org>
References: <1342139517-3451-1-git-send-email-walken@google.com>
	<1342139517-3451-6-git-send-email-walken@google.com>
	<20120713131514.86ab4df4.akpm@linux-foundation.org>
Date: Fri, 13 Jul 2012 15:33:35 -0700
Message-ID: <CANN689FUm83vGFVF30Lg52_28vxdY+mZ88jVCGpmVfiHiHwNtg@mail.gmail.com>
Subject: Re: [PATCH v2 05/12] rbtree: performance and correctness test
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Fri, Jul 13, 2012 at 1:15 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 12 Jul 2012 17:31:50 -0700 Michel Lespinasse <walken@google.com> wrote:
>>  Makefile            |    2 +-
>>  lib/Kconfig.debug   |    1 +
>>  tests/Kconfig       |   18 +++++++
>>  tests/Makefile      |    1 +
>>  tests/rbtree_test.c |  135 +++++++++++++++++++++++++++++++++++++++++++++++++++
>
> This patch does a new thing: adds a kernel self-test module into
> lib/tests/ and sets up the infrastructure to add new kernel self-test
> modules in that directory.
>
> I don't see a problem with this per-se, but it is a new thing which we
> should think about.
>
> In previous such cases (eg, kernel/rcutorture.c) we put those modules
> into the same directory as the code which is being tested.  So to
> follow that pattern, this new code would have gone into lib/.
>
> If we adopt your new proposal then we should perhaps also move tests
> such as rcutorture over into tests/.  And that makes one wonder whether
> we should have a standalone directory for kernel selftest modules.  eg
> tests/self-test-nmodules/.

Ah, I did not realize we had a precedent for in-tree kernel test modules.

I don't think my proposal was significantly better than this
precedent, so I'll just adjust my patch to conform to it:
- move rbtree_test.c to lib/
- modify just lib/Makefile and lib/Kconfig.debug to get the module built.

Will send a replacement patch for this (so you can drop that one patch
from the stack and replace it with)

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
