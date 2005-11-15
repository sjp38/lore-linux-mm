Message-ID: <4379A399.1080407@yahoo.com.au>
Date: Tue, 15 Nov 2005 20:00:09 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 03/05] mm rationalize __alloc_pages ALLOC_* flag names
References: <20051114040329.13951.39891.sendpatchset@jackhammer.engr.sgi.com> <20051114040353.13951.82602.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20051114040353.13951.82602.sendpatchset@jackhammer.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Simon Derr <Simon.Derr@bull.net>, Christoph Lameter <clameter@sgi.com>, "Rohit, Seth" <rohit.seth@intel.com>
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Rationalize mm/page_alloc.c:__alloc_pages() ALLOC flag names.
> 

I don't really see the need for this. The names aren't
clearly better, and the downside is that they move away
from the terminlogy we've been using in the page allocator
for the past few years.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
