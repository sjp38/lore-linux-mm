Date: Tue, 7 May 2002 07:48:26 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] dcache and rmap
Message-ID: <20020507144826.GO15756@holomorphy.com>
References: <200205052117.16268.tomlins@cam.org> <20020507014414.GL15756@holomorphy.com> <200205070741.52896.tomlins@cam.org> <20020507125712.GM15756@holomorphy.com> <20020507151057.A6543@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020507151057.A6543@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2002 at 03:10:57PM +0100, Christoph Hellwig wrote:
> <hint>
> In newer Solaris versions (at least SunOS 5.7/5.8) kmem_cache_t has a new
> method to allow reclaiming of objects on memory pressure.
> </hint>

Well, it can't be that bad of an idea then. I still like keeping the
things separate, but maybe there just isn't that much difference.

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
