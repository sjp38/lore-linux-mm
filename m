Message-ID: <45FF488E.6060707@yahoo.com.au>
Date: Tue, 20 Mar 2007 13:35:58 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com> <20070317043545.GH8915@holomorphy.com> <45FE261F.3030903@yahoo.com.au> <20070319120347.GB6694@lnx-holt.americas.sgi.com>
In-Reply-To: <20070319120347.GB6694@lnx-holt.americas.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
> On Mon, Mar 19, 2007 at 04:56:47PM +1100, Nick Piggin wrote:
> 
>>Yes, I have the patch to do it quite easily. Per-node ZERO_PAGE could be
>>another option, but that's going to cost another page flag if we wish to
>>recognise the zero page in wp faults like we do now (hmm, for some reason
>>it is OK to special case it _there_).
> 
> 
> Could we do a per-node ZERO_PAGE as a pointer from the node structure
> and then use a page_to_nid to get back to the node and compare the page
> to the node's zero page instead of using another page flag which would
> actually only be used on numa?

Yes, that's a nice way to do it.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
