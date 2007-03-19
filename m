Date: Mon, 19 Mar 2007 07:03:47 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
Message-ID: <20070319120347.GB6694@lnx-holt.americas.sgi.com>
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com> <20070317043545.GH8915@holomorphy.com> <45FE261F.3030903@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45FE261F.3030903@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 19, 2007 at 04:56:47PM +1100, Nick Piggin wrote:
> Yes, I have the patch to do it quite easily. Per-node ZERO_PAGE could be
> another option, but that's going to cost another page flag if we wish to
> recognise the zero page in wp faults like we do now (hmm, for some reason
> it is OK to special case it _there_).

Could we do a per-node ZERO_PAGE as a pointer from the node structure
and then use a page_to_nid to get back to the node and compare the page
to the node's zero page instead of using another page flag which would
actually only be used on numa?

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
