Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 790376B0072
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 21:26:50 -0400 (EDT)
Date: Fri, 7 Sep 2012 22:26:41 -0300
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v2 07/12] rbtree: adjust root color in rb_insert_color()
 only when necessary
Message-ID: <20120908012641.GA2177@infradead.org>
References: <1342139517-3451-1-git-send-email-walken@google.com>
 <1342139517-3451-8-git-send-email-walken@google.com>
 <50406F60.5040707@intel.com>
 <CANN689EBA6yPk3pS-yXZ1-ticG7eU3mY1mWMWp2S3xhJ73ODFA@mail.gmail.com>
 <20120831011541.ddf8ed78.akpm@linux-foundation.org>
 <5040775C.3070205@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5040775C.3070205@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adrian Hunter <adrian.hunter@intel.com>
Cc: "Shishkin, Alexander" <alexander.shishkin@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Em Fri, Aug 31, 2012 at 11:35:40AM +0300, Adrian Hunter escreveu:
> AFAICS tools/perf/util/include/linux is for fixing up the
> differences between kernel headers and exported kernel headers.
> Hence my change:
> 
> diff --git a/tools/perf/util/include/linux/rbtree.h b/tools/perf/util/include/linux/rbtree.h
> index 7a243a1..2a030c5 100644
> --- a/tools/perf/util/include/linux/rbtree.h
> +++ b/tools/perf/util/include/linux/rbtree.h
> @@ -1 +1,2 @@
> +#include <stdbool.h>
>  #include "../../../../include/linux/rbtree.h"

I applied this one now, thanks,

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
