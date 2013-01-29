Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 648A96B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 20:44:20 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id wz17so590278pbc.29
        for <linux-mm@kvack.org>; Mon, 28 Jan 2013 17:44:19 -0800 (PST)
Date: Mon, 28 Jan 2013 17:44:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/11] ksm: trivial tidyups
In-Reply-To: <20130128151119.b74d0150.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1301281738570.4947@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251757020.29196@eggly.anvils> <20130128151119.b74d0150.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Jan 2013, Andrew Morton wrote:
> On Fri, 25 Jan 2013 17:58:11 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > +#ifdef CONFIG_NUMA
> > +#define NUMA(x)		(x)
> > +#define DO_NUMA(x)	(x)
> 
> Did we consider
> 
> 	#define DO_NUMA do { (x) } while (0)
> 
> ?

It didn't occur to me at all.  I like that it makes more sense of
the DO_NUMA variant.  Is it okay that, to work with the way I was
using it, we need "(x);" in there rather than just "(x)"?

> 
> That could avoid some nasty config-dependent compilation issues.
> 
> > +#else
> > +#define NUMA(x)		(0)

[PATCH] ksm: trivial tidyups fix

Suggested by akpm: make DO_NUMA(x) do { (x); } while (0) more like the #else.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/ksm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm.org/mm/ksm.c	2013-01-27 09:55:45.000000000 -0800
+++ mmotm/mm/ksm.c	2013-01-28 16:50:25.772026446 -0800
@@ -43,7 +43,7 @@
 
 #ifdef CONFIG_NUMA
 #define NUMA(x)		(x)
-#define DO_NUMA(x)	(x)
+#define DO_NUMA(x)	do { (x); } while (0)
 #else
 #define NUMA(x)		(0)
 #define DO_NUMA(x)	do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
