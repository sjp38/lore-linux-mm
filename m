Message-ID: <4379A1C4.509@yahoo.com.au>
Date: Tue, 15 Nov 2005 19:52:20 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 01/05] mm fix __alloc_pages cpuset ALLOC_* flags
References: <20051114040329.13951.39891.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20051114040329.13951.39891.sendpatchset@jackhammer.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Simon Derr <Simon.Derr@bull.net>, Christoph Lameter <clameter@sgi.com>, "Rohit, Seth" <rohit.seth@intel.com>
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Two changes to the setting of the ALLOC_CPUSET flag in
> mm/page_alloc.c:__alloc_pages()
> 
>  1) A bug fix - the "ignoring mins" case should not be honoring
>     ALLOC_CPUSET.  This case of all cases, since it is handling a
>     request that will free up more memory than is asked for (exiting
>     tasks, e.g.) should be allowed to escape cpuset constraints
>     when memory is tight.
> 
>  2) A logic change to make it simpler.  Honor cpusets even on
>     GFP_ATOMIC (!wait) requests.  With this, cpuset confinement
>     applies to all requests except ALLOC_NO_WATERMARKS, so that
>     in a subsequent cleanup patch, I can remove the ALLOC_CPUSET
>     flag entirely.  Since I don't know any real reason this
>     logic has to be either way, I am choosing the path of the
>     simplest code.
> 

Hi,

I think #1 is OK, however I was under the impression that you
introduced the exception reverted in #2 due to seeing atomic
allocation failures?!

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
