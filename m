Date: Fri, 27 Jan 2006 09:10:47 +0200 (EET)
From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [patch 8/9] slab - Add *_mempool slab variants
In-Reply-To: <43D94FC1.4050708@us.ibm.com>
Message-ID: <Pine.LNX.4.58.0601270910000.14394@sbz-30.cs.Helsinki.FI>
References: <20060125161321.647368000@localhost.localdomain>
 <1138218020.2092.8.camel@localhost.localdomain>
 <84144f020601252341k62c0c6fck57f3baa290f4430@mail.gmail.com>
 <43D94FC1.4050708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jan 2006, Matthew Dobson wrote:
> I decided that using a whole page allocator would be the easiest way to
> cover the most common uses of slab/kmalloc, but your idea is very
> interesting.  My immediate concern would be trying to determine, at kfree()
> time, what was allocated by the slab allocator and what was allocated by
> the critical pool.  I will give this approach more thought, as the idea of
> completely separating the critical pool and slab allocator is attractive.

I think you can use PageSlab for that.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
