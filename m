Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 81A556B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 15:43:30 -0400 (EDT)
Message-ID: <1343418204.32120.40.camel@twins>
Subject: Re: [PATCH 5/6] rbtree: faster augmented erase
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 27 Jul 2012 21:43:24 +0200
In-Reply-To: <1342787467-5493-6-git-send-email-walken@google.com>
References: <1342787467-5493-1-git-send-email-walken@google.com>
	 <1342787467-5493-6-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-07-20 at 05:31 -0700, Michel Lespinasse wrote:
> --- a/lib/rbtree_test.c
> +++ b/lib/rbtree_test.c
> @@ -1,5 +1,6 @@
>  #include <linux/module.h>
>  #include <linux/rbtree.h>
> +#include <linux/rbtree_internal.h>=20

This confuses me.. either its internal to the rb-tree implementation and
users don't need to see it, or its not in which case huh?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
