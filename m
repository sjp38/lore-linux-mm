Date: Sat, 29 Oct 2005 19:26:11 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Clean up of __alloc_pages
Message-Id: <20051029192611.79b9c5e7.pj@sgi.com>
In-Reply-To: <4364296E.1080905@yahoo.com.au>
References: <20051028183326.A28611@unix-os.sc.intel.com>
	<20051029184728.100e3058.pj@sgi.com>
	<4364296E.1080905@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rohit.seth@intel.com, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> >  2) The can_try_harder flag values were driving me nuts.
> 
> Please instead use a second argument 'gfp_high', which will nicely
> match zone_watermark_ok, and use that consistently when converting
> __alloc_pages code to use get_page_from_freelist. Ie. keep current
> behaviour.

Well ... I still don't understand what you're suggesting, so I
guess I will have to wait for an actual patch incorporating it.

Are you also objecting to converting "can_try_harder" to an
enum, and getting the values in order of desperation?  If so,
I don't why you object.

And there is still the issue that I don't think cpuset constraints
should be applied in the last attempt before oom_killing for
GFP_ATOMIC requests.

I will await the next version of the patch, and see if it meets
my concerns.  I am missing a couple too many clues to add more
at this point.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
