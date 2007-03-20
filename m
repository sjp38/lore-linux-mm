Message-ID: <45FF4CAB.2000306@yahoo.com.au>
Date: Tue, 20 Mar 2007 13:53:31 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com> <20070317043545.GH8915@holomorphy.com> <45FE261F.3030903@yahoo.com.au> <45FE2CA0.3080204@yahoo.com.au> <Pine.LNX.4.64.0703191005530.23929@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703191005530.23929@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 19 Mar 2007, Nick Piggin wrote:
> 
> 
>>I haven't booted this, but it is a quick forward port + some fixes and
>>simplifications.
> 
> 
> Eeek patch vanished.
> 
> The comparison with ZERO_PAGE may fail if we have multiple zero pages. 
> Would it be possible to check for PageReserved?

That still wasn't quite right either.

I don't want to check for PageReserved, because I want to get rid of
that flag one day. The Robin/Bill approach for multiple zero pages
will work, though.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
