Date: Mon, 26 Mar 2007 17:02:10 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch 2/3] only allow nonlinear vmas for ram backed filesystems
Message-ID: <20070327000210.GZ2986@holomorphy.com>
References: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu> <E1HVEQJ-0006gF-00@dorka.pomaz.szeredi.hu> <1174824752.5149.28.camel@lappy> <20070325155127.GR10459@waste.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070325155127.GR10459@waste.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2007-03-24 at 23:09 +0100, Miklos Szeredi wrote:
>>> Dirty page accounting/limiting doesn't work for nonlinear mappings, so
>>> for non-ram backed filesystems emulate with linear mappings.  This
>>> retains ABI compatibility with previous kernels at minimal code cost.
>>> All known users of nonlinear mappings actually use tmpfs, so this
>>> shouldn't have any negative effect.

On Sun, Mar 25, 2007 at 02:12:32PM +0200, Peter Zijlstra wrote:

On Sun, Mar 25, 2007 at 10:51:27AM -0500, Matt Mackall wrote:
> They do? I thought the whole point of nonlinear mappings was for
> mapping files bigger than the address space (eg. databases). Is Oracle
> instead using this to map >3G files on a tmpfs??

It's used for > 3GB files on tmpfs and also ramfs, sometimes
substantially larger than 3GB.

It's not used for the database proper. It's used for the buffer pool,
which is the in-core destination and source of direct I/O, the on-disk
source and destination of the I/O being the database.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
