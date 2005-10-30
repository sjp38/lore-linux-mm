Message-ID: <43643195.9040600@yahoo.com.au>
Date: Sun, 30 Oct 2005 13:36:05 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	<20051029184728.100e3058.pj@sgi.com>	<4364296E.1080905@yahoo.com.au> <20051029192611.79b9c5e7.pj@sgi.com>
In-Reply-To: <20051029192611.79b9c5e7.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rohit.seth@intel.com, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
>>> 2) The can_try_harder flag values were driving me nuts.
>>
>>Please instead use a second argument 'gfp_high', which will nicely
>>match zone_watermark_ok, and use that consistently when converting
>>__alloc_pages code to use get_page_from_freelist. Ie. keep current
>>behaviour.
> 
> 
> Well ... I still don't understand what you're suggesting, so I
> guess I will have to wait for an actual patch incorporating it.
> 

See how can_try_harder and gfp_high is used currently. They
are simple boolean values and are easily derived from parameters
passed into __alloc_pages.

> Are you also objecting to converting "can_try_harder" to an
> enum, and getting the values in order of desperation?  If so,
> I don't why you object.
> 

Because then to get current behaviour you would have to add
branches to get the correct enum value.

> And there is still the issue that I don't think cpuset constraints
> should be applied in the last attempt before oom_killing for
> GFP_ATOMIC requests.
> 

Sure.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
