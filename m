From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC] My research agenda for 2.7
Date: Tue, 24 Jun 2003 17:47:58 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030625004758.GO26348@holomorphy.com>
References: <200306250111.01498.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200306250111.01498.phillips@arcor.de>
To: Daniel Phillips <phillips@arcor.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed, Jun 25, 2003 at 01:11:01AM +0200, Daniel Phillips wrote:
>   - Page size is represented on a per-address space basis with a shift count.
>     In practice, the smallest is 9 (512 byte sector), could imagine 7 (each
>     ext2 inode is separate page) or 8 (actual hardsect size on some drives).
>     12 will be the most common size.  13 gives 8K blocksize for, e.g., alpha.
>     21 and 22 give 2M and 4M page size, matching hardware capabilities of
>     x86, and other sizes are possible on machines like MIPS, where page size
>     is software controllable
>   - Implemented only for file-backed memory (page cache)

Per struct address_space? This is an unnecessary limitation.


On Wed, Jun 25, 2003 at 01:11:01AM +0200, Daniel Phillips wrote:
>   - Special case these ops in page cache access layer instead of having the
>     messy code in the block IO library
>   - Subpage struct pages are dynamically allocated.  But buffer_heads are gone
>     so this is a lateral change.

This gives me the same data structure proliferation chills as bh's.


-- wli
