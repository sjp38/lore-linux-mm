From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC] My research agenda for 2.7
Date: Tue, 24 Jun 2003 18:10:31 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030625011031.GP26348@holomorphy.com>
References: <200306250111.01498.phillips@arcor.de> <20030625004758.GO26348@holomorphy.com> <200306250307.18291.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200306250307.18291.phillips@arcor.de>
To: Daniel Phillips <phillips@arcor.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wednesday 25 June 2003 02:47, William Lee Irwin III wrote:
>> Per struct address_space? This is an unnecessary limitation.

On Wed, Jun 25, 2003 at 03:07:18AM +0200, Daniel Phillips wrote:
> It's a sensible limitation, it keeps the radix tree lookup simple.

It severely limits its usefulness. Dropping in a more flexible data
structure should be fine.


On Wednesday 25 June 2003 02:47, William Lee Irwin III wrote:
>> This gives me the same data structure proliferation chills as bh's.

On Wed, Jun 25, 2003 at 03:07:18AM +0200, Daniel Phillips wrote:
> It's not nearly as bad.  There is no distinction between subpage and base 
> struct page for almost all page operations, e.g., locking, IO, data access.

But those are code sanitation issues. You need to make sure this
doesn't explode on PAE.


-- wli
