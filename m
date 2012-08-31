Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8AC3E6B006C
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 04:07:26 -0400 (EDT)
Received: by iec9 with SMTP id 9so1870915iec.14
        for <linux-mm@kvack.org>; Fri, 31 Aug 2012 01:07:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50406F60.5040707@intel.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
	<1342139517-3451-8-git-send-email-walken@google.com>
	<50406F60.5040707@intel.com>
Date: Fri, 31 Aug 2012 01:07:24 -0700
Message-ID: <CANN689EBA6yPk3pS-yXZ1-ticG7eU3mY1mWMWp2S3xhJ73ODFA@mail.gmail.com>
Subject: Re: [PATCH v2 07/12] rbtree: adjust root color in rb_insert_color()
 only when necessary
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adrian Hunter <adrian.hunter@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, acme@redhat.com

On Fri, Aug 31, 2012 at 1:01 AM, Adrian Hunter <adrian.hunter@intel.com> wrote:
> This breaks tools/perf build in linux-next:
>
> ../../lib/rbtree.c: In function 'rb_insert_color':
> ../../lib/rbtree.c:95:9: error: 'true' undeclared (first use in this function)
> ../../lib/rbtree.c:95:9: note: each undeclared identifier is reported only once for each function it appears in
> ../../lib/rbtree.c: In function '__rb_erase_color':
> ../../lib/rbtree.c:216:9: error: 'true' undeclared (first use in this function)
> ../../lib/rbtree.c: In function 'rb_erase':
> ../../lib/rbtree.c:368:2: error: unknown type name 'bool'
> make: *** [util/rbtree.o] Error 1

I thought Andrew had a patch
rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix-perf-compilation
that fixed this though a Makefile change ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
