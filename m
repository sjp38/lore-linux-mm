Message-ID: <46A03E63.2080508@yahoo.com.au>
Date: Fri, 20 Jul 2007 14:47:31 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlbfs read() support
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com> <20070718221950.35bbdb76.akpm@linux-foundation.org> <1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com> <20070719095850.6e09b0e8.akpm@linux-foundation.org> <20070719170759.GE2083@us.ibm.com>
In-Reply-To: <20070719170759.GE2083@us.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Bill Irwin <bill.irwin@oracle.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote:
> On 19.07.2007 [09:58:50 -0700], Andrew Morton wrote:
> 
>>On Thu, 19 Jul 2007 08:51:49 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:
>>
>>
>>>>>+		}
>>>>>+
>>>>>+		offset += ret;
>>>>>+		retval += ret;
>>>>>+		len -= ret;
>>>>>+		index += offset >> HPAGE_SHIFT;
>>>>>+		offset &= ~HPAGE_MASK;
>>>>>+
>>>>>+		page_cache_release(page);
>>>>>+		if (ret == nr && len)
>>>>>+			continue;
>>>>>+		goto out;
>>>>>+	}
>>>>>+out:
>>>>>+	return retval;
>>>>>+}
>>>>
>>>>This code doesn't have all the ghastly tricks which we deploy to
>>>>handle concurrent truncate.
>>>
>>>Do I need to ? Baaahh!!  I don't want to deal with them. 
>>
>>Nick, can you think of any serious consequences of a read/truncate
>>race in there?  I can't..
>>
>>
>>>All I want is a simple read() to get my oprofile working.  Please
>>>advise.
>>
>>Did you consider changing oprofile userspace to read the executable
>>with mmap?
> 
> 
> It's not actually oprofile's code, though, it's libbfd (used by
> oprofile). And it works fine (presumably) for other binaries.

So... what's the problem with changing it? The fact that it is a
library doesn't really make a difference except that you'll also
help everyone else who links with it.

It won't break backwards compatibility, and it will work on older
kernels...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
