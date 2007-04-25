Date: Wed, 25 Apr 2007 08:54:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 05/16] Variable Order Page Cache: Add functions to establish
 sizes
In-Reply-To: <20070425112051.GD19942@skynet.ie>
Message-ID: <Pine.LNX.4.64.0704250848320.24530@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
 <20070423064911.5458.40889.sendpatchset@schroedinger.engr.sgi.com>
 <20070425112051.GD19942@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Apr 2007, Mel Gorman wrote:

> These all need comments in the source, particularly page_cache_index() so
> that it is clear that the index is "number of compound pages", not number
> of base pages. With the name as-is, it could be either.  page_cache_offset()
> requires similar mental gymnastics to understand without some sort of comment.

I added some comments explaining it for V4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
