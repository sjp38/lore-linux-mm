Message-ID: <46A05270.5040205@yahoo.com.au>
Date: Fri, 20 Jul 2007 16:13:04 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlbfs read() support
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com>	<20070718221950.35bbdb76.akpm@linux-foundation.org>	<1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com> <20070719095850.6e09b0e8.akpm@linux-foundation.org>
In-Reply-To: <20070719095850.6e09b0e8.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Bill Irwin <bill.irwin@oracle.com>, nacc@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(sorry if this is a resend... something bad seems to have happened to me)

Andrew Morton wrote:
> On Thu, 19 Jul 2007 08:51:49 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:

>>>This code doesn't have all the ghastly tricks which we deploy to handle
>>>concurrent truncate.
>>
>>Do I need to ? Baaahh!!  I don't want to deal with them. 
> 
> 
> Nick, can you think of any serious consequences of a read/truncate race in
> there?  I can't..

As it doesn't allow writes, then I _think_ it should be OK. If you
ever did want to add write(2) support, then you would have transient
zeroes problems.

But I'm not completely sure.. we've had a lot of (and still have
some known and probably unknown) bugs just in that single
generic_mapping_read function, most of which are due to our rabid
aversion to doing any locking whatsoever there.

So why not just hold i_mutex around the whole thing to be safe?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
