From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Fri, 27 Jun 2003 17:50:52 +0200
References: <200306250111.01498.phillips@arcor.de> <200306271717.01562.phillips@arcor.de> <Pine.LNX.4.53.0306271617210.21548@skynet>
In-Reply-To: <Pine.LNX.4.53.0306271617210.21548@skynet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306271750.52362.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 27 June 2003 17:22, Mel Gorman wrote:
> I still suspect moving order0 allocations to slab will be a fragmentation
> resistent allocator but my main concern would be that the slab allocator
> overhead, both CPU and storage requirements will be too high.
>
> On the other hand, it would do some things you are looking for. For
> example, it allocates large blocks of memory in one lump and then
> allocates them piecemeal. Second, it would be resistent to the FAFAFA
> problem Martin pointed out. As slabs would be allocated in a large block
> from the buddy, you are guarenteed that you'll be able to free up buddies.
> Lastly, as there would be a cache specifically for userspace pages, a
> defragger that looked exclusively at user pages will still be sure of
> being able to free adjacent buddies.
>
> I need to write a proper RFC.....

You might want to have a look at this:

   http://www.research.att.com/sw/tools/vmalloc/
   (Vmalloc: A Memory Allocation Library)

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
