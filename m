Date: Mon, 23 Apr 2007 18:11:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 15/16] ext2: Add variable page size support
In-Reply-To: <1177345812.19676.4.camel@dyn9047017100.beaverton.ibm.com>
Message-ID: <Pine.LNX.4.64.0704231810360.3880@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
  <20070423065003.5458.83524.sendpatchset@schroedinger.engr.sgi.com>
 <1177345812.19676.4.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Adam Litke <aglitke@gmail.com>, Avi Kivity <avi@argo.co.il>, Mel Gorman <mel@skynet.ie>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Apr 2007, Badari Pulavarty wrote:

> Here is the fix you need to get ext2 writeback working properly :)
> I am able to run fsx with this fix (without mapped IO).

Yes it works! Great. Now if I just had an idea why reclaim does not work 
and why the active page vanish....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
