From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Wed, 25 Jun 2003 03:07:18 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200306250307.18291.phillips@arcor.de>
References: <200306250111.01498.phillips@arcor.de> <20030625004758.GO26348@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-Reply-To: <20030625004758.GO26348@holomorphy.com>
Content-Disposition: inline
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wednesday 25 June 2003 02:47, William Lee Irwin III wrote:
> On Wed, Jun 25, 2003 at 01:11:01AM +0200, Daniel Phillips wrote:
> >   - Page size is represented on a per-address space basis with a shift
> > count. In practice, the smallest is 9 (512 byte sector), could imagine 7
> > (each ext2 inode is separate page) or 8 (actual hardsect size on some
> > drives). 12 will be the most common size.  13 gives 8K blocksize for,
> > e.g., alpha. 21 and 22 give 2M and 4M page size, matching hardware
> > capabilities of x86, and other sizes are possible on machines like MIPS,
> > where page size is software controllable
> >   - Implemented only for file-backed memory (page cache)
>
> Per struct address_space? This is an unnecessary limitation.

It's a sensible limitation, it keeps the radix tree lookup simple.

> On Wed, Jun 25, 2003 at 01:11:01AM +0200, Daniel Phillips wrote:
> >   - Special case these ops in page cache access layer instead of having
> > the messy code in the block IO library
> >   - Subpage struct pages are dynamically allocated.  But buffer_heads are
> > gone so this is a lateral change.
>
> This gives me the same data structure proliferation chills as bh's.

It's not nearly as bad.  There is no distinction between subpage and base 
struct page for almost all page operations, e.g., locking, IO, data access.

Regards,

Daniel
