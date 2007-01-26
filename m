Message-ID: <45B9A00C.4040701@yahoo.com.au>
Date: Fri, 26 Jan 2007 17:30:36 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Track mlock()ed pages
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Add NR_MLOCK
> 
> Track mlocked pages via a ZVC

I think it is not quite right. You are tracking the number of ptes
that point to mlocked pages, which can be >= the actual number of pages.

Also, page_add_anon_rmap still needs to be balanced with page_remove_rmap.

I can't think of an easy way to do this without per-page state. ie.
another page flag.

> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
