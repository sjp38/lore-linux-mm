Message-ID: <4364442C.1070209@yahoo.com.au>
Date: Sun, 30 Oct 2005 14:55:24 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	<20051029184728.100e3058.pj@sgi.com>	<4364296E.1080905@yahoo.com.au>	<20051029192611.79b9c5e7.pj@sgi.com>	<43643195.9040600@yahoo.com.au> <20051029200916.61a32331.pj@sgi.com>
In-Reply-To: <20051029200916.61a32331.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rohit.seth@intel.com, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Nick wrote:
> 
>>See how can_try_harder and gfp_high is used currently. 
> 
> 
> Ah - by "current" you meant in Linus's or Andrew's tree,
> not as in Seth's current patch.  Since they are booleans,
> rather than tri-values, using an enum is overkill.  Ok.
> 

Yup.

> Now I'm one less clue short of understanding.  Thanks.
> 

I'll be more constructive next time round, and provide an
actual patch to address any of my remaining concerns after
this latest round of feedback.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
