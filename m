From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC] My research agenda for 2.7
Date: Tue, 24 Jun 2003 18:30:50 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030625013050.GQ26348@holomorphy.com>
References: <200306250111.01498.phillips@arcor.de> <200306250307.18291.phillips@arcor.de> <20030625011031.GP26348@holomorphy.com> <200306250325.47529.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200306250325.47529.phillips@arcor.de>
To: Daniel Phillips <phillips@arcor.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wednesday 25 June 2003 03:10, William Lee Irwin III wrote:
>> It severely limits its usefulness. Dropping in a more flexible data
>> structure should be fine.

On Wed, Jun 25, 2003 at 03:25:47AM +0200, Daniel Phillips wrote:
> Eventually it could well make sense to do that, e.g., the radix tree 
> eventually ought to evolve into a btree of extents (probably).  But making 
> things so complex in the first version, thus losing much of the incremental 
> development advantage, would not be smart.  With a single size of page per 
> address_space,  changes to the radix tree code are limited to a couple of 
> lines, for example.
> But perhaps you'd like to supply some examples where more than one size of 
> page in the same address space really matters?

Software-refill TLB architectures would very much like to be handed the
largest physically contiguous chunk of memory out of pagecache possible
and map it out using the fewest number of TLB entries possible. Dropping
in a B+ tree to replace radix trees should be a weekend project at worst.
Speculatively allocating elements that are "as large as sane/possible"
will invariably result in variable-sized elements in the same tree.


-- wli
