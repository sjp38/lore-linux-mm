Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 307496B005A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 16:15:16 -0400 (EDT)
Date: Fri, 13 Jul 2012 13:15:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 05/12] rbtree: performance and correctness test
Message-Id: <20120713131514.86ab4df4.akpm@linux-foundation.org>
In-Reply-To: <1342139517-3451-6-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
	<1342139517-3451-6-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, 12 Jul 2012 17:31:50 -0700
Michel Lespinasse <walken@google.com> wrote:

> This small module helps measure the performance of rbtree insert and erase.
> 
> Additionally, we run a few correctness tests to check that the rbtrees have
> all desired properties:
> - contains the right number of nodes in the order desired,
> - never two consecutive red nodes on any path,
> - all paths to leaf nodes have the same number of black nodes,
> - root node is black
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  Makefile            |    2 +-
>  lib/Kconfig.debug   |    1 +
>  tests/Kconfig       |   18 +++++++
>  tests/Makefile      |    1 +
>  tests/rbtree_test.c |  135 +++++++++++++++++++++++++++++++++++++++++++++++++++

This patch does a new thing: adds a kernel self-test module into
lib/tests/ and sets up the infrastructure to add new kernel self-test
modules in that directory.

I don't see a problem with this per-se, but it is a new thing which we
should think about.

In previous such cases (eg, kernel/rcutorture.c) we put those modules
into the same directory as the code which is being tested.  So to
follow that pattern, this new code would have gone into lib/.

If we adopt your new proposal then we should perhaps also move tests
such as rcutorture over into tests/.  And that makes one wonder whether
we should have a standalone directory for kernel selftest modules.  eg
tests/self-test-nmodules/.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
