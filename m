Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 575886B006C
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 05:24:43 -0400 (EDT)
From: Alexander Shishkin <alexander.shishkin@intel.com>
Subject: Re: [PATCH v2 07/12] rbtree: adjust root color in rb_insert_color() only when necessary
In-Reply-To: <5040775C.3070205@intel.com>
References: <1342139517-3451-1-git-send-email-walken@google.com> <1342139517-3451-8-git-send-email-walken@google.com> <50406F60.5040707@intel.com> <CANN689EBA6yPk3pS-yXZ1-ticG7eU3mY1mWMWp2S3xhJ73ODFA@mail.gmail.com> <20120831011541.ddf8ed78.akpm@linux-foundation.org> <5040775C.3070205@intel.com>
Date: Fri, 31 Aug 2012 12:25:10 +0300
Message-ID: <87txvjifbd.fsf@ashishki-desk.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adrian Hunter <adrian.hunter@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, acme@redhat.com

Adrian Hunter <adrian.hunter@intel.com> writes:

> On 31/08/12 11:15, Andrew Morton wrote:
>> On Fri, 31 Aug 2012 01:07:24 -0700 Michel Lespinasse <walken@google.com> wrote:
>> 
>>> On Fri, Aug 31, 2012 at 1:01 AM, Adrian Hunter <adrian.hunter@intel.com> wrote:
>>>> This breaks tools/perf build in linux-next:
>>>>
>>>> ../../lib/rbtree.c: In function 'rb_insert_color':
>>>> ../../lib/rbtree.c:95:9: error: 'true' undeclared (first use in this function)
>>>> ../../lib/rbtree.c:95:9: note: each undeclared identifier is reported only once for each function it appears in
>>>> ../../lib/rbtree.c: In function '__rb_erase_color':
>>>> ../../lib/rbtree.c:216:9: error: 'true' undeclared (first use in this function)
>>>> ../../lib/rbtree.c: In function 'rb_erase':
>>>> ../../lib/rbtree.c:368:2: error: unknown type name 'bool'
>>>> make: *** [util/rbtree.o] Error 1
>>>
>>> I thought Andrew had a patch
>>> rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix-perf-compilation
>>> that fixed this though a Makefile change ?
>> 
>> Yup.  But it's unclear why we should include the header via the cc
>> command line?
>
> Dunno
>
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
>
> Alex?

Whichever color like best. :) Consider my initial patch a bugreport.

Regards,
--
Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
