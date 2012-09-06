Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 57BF06B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 16:47:20 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so3375149pbb.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 13:47:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANN689E8u-rx08NMG3JRaay1BdM=VTe6nzE_FfcPSFSShbL=9A@mail.gmail.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
	<1342139517-3451-8-git-send-email-walken@google.com>
	<50406F60.5040707@intel.com>
	<CANN689EBA6yPk3pS-yXZ1-ticG7eU3mY1mWMWp2S3xhJ73ODFA@mail.gmail.com>
	<20120831011541.ddf8ed78.akpm@linux-foundation.org>
	<5040775C.3070205@intel.com>
	<CANN689E8u-rx08NMG3JRaay1BdM=VTe6nzE_FfcPSFSShbL=9A@mail.gmail.com>
Date: Thu, 6 Sep 2012 13:47:19 -0700
Message-ID: <CAOesGMg_ash8spRvqYGPYfoDLAG13+ATqmQGa1ZOZoj0u8ZfjA@mail.gmail.com>
Subject: Re: [PATCH v2 07/12] rbtree: adjust root color in rb_insert_color()
 only when necessary
From: Olof Johansson <olof@lixom.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Adrian Hunter <adrian.hunter@intel.com>, "Shishkin, Alexander" <alexander.shishkin@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, acme@redhat.com

On Fri, Aug 31, 2012 at 1:39 AM, Michel Lespinasse <walken@google.com> wrote:
> On Fri, Aug 31, 2012 at 1:35 AM, Adrian Hunter <adrian.hunter@intel.com> wrote:
>> On 31/08/12 11:15, Andrew Morton wrote:
>>> On Fri, 31 Aug 2012 01:07:24 -0700 Michel Lespinasse <walken@google.com> wrote:
>>>> I thought Andrew had a patch
>>>> rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix-perf-compilation
>>>> that fixed this though a Makefile change ?
>>>
>>> Yup.  But it's unclear why we should include the header via the cc
>>> command line?
>>
>> Dunno
>>
>> AFAICS tools/perf/util/include/linux is for fixing up the
>> differences between kernel headers and exported kernel headers.
>> Hence my change:
>>
>> diff --git a/tools/perf/util/include/linux/rbtree.h b/tools/perf/util/include/linux/rbtree.h
>> index 7a243a1..2a030c5 100644
>> --- a/tools/perf/util/include/linux/rbtree.h
>> +++ b/tools/perf/util/include/linux/rbtree.h
>> @@ -1 +1,2 @@
>> +#include <stdbool.h>
>>  #include "../../../../include/linux/rbtree.h"
>>
>> Alex?
>
> Ah, makes sense to me. I wasn't previously aware of the
> tools/perf/util/include/linux directory. I think your fix is fine.
> (I don't understand how you hit the issue given the previous Makefile
> fix, but I think your fix looks nicer)

Looks like the Makefile change either never landed, or has since been dropped.

Can we please get this one picked up? Without it, perf is unbuildable
on linux-next.


-Olof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
