From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Wed, 25 Jun 2003 03:25:47 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200306250325.47529.phillips@arcor.de>
References: <200306250111.01498.phillips@arcor.de> <200306250307.18291.phillips@arcor.de> <20030625011031.GP26348@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-Reply-To: <20030625011031.GP26348@holomorphy.com>
Content-Disposition: inline
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wednesday 25 June 2003 03:10, William Lee Irwin III wrote:
> On Wednesday 25 June 2003 02:47, William Lee Irwin III wrote:
> >> Per struct address_space? This is an unnecessary limitation.
>
> On Wed, Jun 25, 2003 at 03:07:18AM +0200, Daniel Phillips wrote:
> > It's a sensible limitation, it keeps the radix tree lookup simple.
>
> It severely limits its usefulness. Dropping in a more flexible data
> structure should be fine.

Eventually it could well make sense to do that, e.g., the radix tree 
eventually ought to evolve into a btree of extents (probably).  But making 
things so complex in the first version, thus losing much of the incremental 
development advantage, would not be smart.  With a single size of page per 
address_space,  changes to the radix tree code are limited to a couple of 
lines, for example.

But perhaps you'd like to supply some examples where more than one size of 
page in the same address space really matters?

> On Wednesday 25 June 2003 02:47, William Lee Irwin III wrote:
> >> This gives me the same data structure proliferation chills as bh's.
>
> On Wed, Jun 25, 2003 at 03:07:18AM +0200, Daniel Phillips wrote:
> > It's not nearly as bad.  There is no distinction between subpage and base
> > struct page for almost all page operations, e.g., locking, IO, data
> > access.
>
> But those are code sanitation issues. You need to make sure this
> doesn't explode on PAE.

Indeed, that is important.  Good night, see you tomorrow.

Daniel
