Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JcuQk-0007a6-Ef
	for linux-mm@kvack.org; Sat, 22 Mar 2008 03:30:02 +0000
Received: from 76.14.48.172 ([76.14.48.172])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 22 Mar 2008 03:30:02 +0000
Received: from blp by 76.14.48.172 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 22 Mar 2008 03:30:02 +0000
From: Ben Pfaff <blp@cs.stanford.edu>
Subject: Re: [patch 2/9] Store max number of objects in the page struct.
Date: Fri, 21 Mar 2008 20:27:31 -0700
Message-ID: <87od975tgc.fsf@blp.benpfaff.org>
References: <20080317230516.078358225@sgi.com> <20080317230528.279983034@sgi.com> <1205917757.10318.1.camel@ymzhang> <Pine.LNX.4.64.0803191049450.29173@schroedinger.engr.sgi.com> <1205983937.14496.24.camel@ymzhang> <20080321152407.b0fbe81f.akpm@linux-foundation.org>
Reply-To: blp@cs.stanford.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

>> +#define USHRT_MAX	((u16)(~0U))
>> +#define SHRT_MAX	((s16)(USHRT_MAX>>1))
>> +#define SHRT_MIN	(-SHRT_MAX - 1)
>
> We have UINT_MAX and ULONG_MAX and ULLONG_MAX.  If these were actually
> UNT_MAX, ULNG_MAX and ULLNG_MAX then USHRT_MAX would make sense.
>
> But they aren't, so it doesn't ;)
>
> Please, let's call them USHORT_MAX, SHORT_MAX and SHORT_MIN.

SHRT_MIN, SHRT_MAX, and USHRT_MAX are the spellings used by
<limits.h> required in ISO-conforming C implementations.  That
doesn't mean that the kernel has to use those spellings, but it
does mean that those names are widely understood by C
programmers.
-- 
Ben Pfaff 
http://benpfaff.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
