From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(), zap_page_range() & follow_page()
Date: Fri, 11 Jul 2008 00:21:28 +1000
References: <20080703213348.489120321@attica.americas.sgi.com> <200807101731.54910.nickpiggin@yahoo.com.au> <20080710132903.GA17830@sgi.com>
In-Reply-To: <20080710132903.GA17830@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807110021.29392.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Hellwig <hch@infradead.org>, cl@linux-foundation.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, andrea@qumranet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 10 July 2008 23:29, Jack Steiner wrote:
> On Thu, Jul 10, 2008 at 05:31:54PM +1000, Nick Piggin wrote:
> > On Thursday 10 July 2008 05:11, Jack Steiner wrote:

> > > I'll post the new GRU patch in a few minutes.
> >
> > It looks broken to me. How does it determine whether it has a
> > normal page or not?
>
> Right. Hugepages are not currently supported by the GRU. There is code that
> I know is missing/broken in this path. I'm trying to get the core driver
> accepted, then I'll get the portion dealing with hugepages working.

Oh, I meant "normal" pages as in vm_normal_page(), or is there some
other reason this codepath is exempt from them?

Using gup.c code I don't think will prevent your driver from getting
accepted. Conversely, I would not like the open coded page table walk
to go upstream...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
