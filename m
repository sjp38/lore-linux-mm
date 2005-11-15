Date: Tue, 15 Nov 2005 01:18:32 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 03/05] mm rationalize __alloc_pages ALLOC_* flag names
Message-Id: <20051115011832.712d03c8.pj@sgi.com>
In-Reply-To: <4379A399.1080407@yahoo.com.au>
References: <20051114040329.13951.39891.sendpatchset@jackhammer.engr.sgi.com>
	<20051114040353.13951.82602.sendpatchset@jackhammer.engr.sgi.com>
	<4379A399.1080407@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Simon.Derr@bull.net, clameter@sgi.com, rohit.seth@intel.com
List-ID: <linux-mm.kvack.org>

Nick wrote:
> the downside is that they move away
> from the terminlogy we've been using in the page allocator
> for the past few years.

I was trying to make the names more readable for the rest of us ;).

In the short term, there is seldom a reason to change names,
as it impacts the current experts more than it helps others.

Over a sufficiently long term, everyone is an 'other'.  Most
of the people who will have reason to want to understand this
code over the next five years are not experts in it now.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
