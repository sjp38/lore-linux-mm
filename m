Date: Tue, 7 May 2002 17:08:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <20020508000857.GA15756@holomorphy.com>
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <E175Avp-0000Tm-00@starship> <20020507195007.GW15756@holomorphy.com> <E175Dy8-0000U6-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <E175Dy8-0000U6-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 21:50, William Lee Irwin III wrote:
>> Generally the way to achieve this is by anticipating those bulk
>> operations and providing standardized methods for them. copy_page_range()
>> and zap_page_range() are already examples of this. For other cases,
>> it's perhaps a useful layer inversion.

On Wed, May 08, 2002 at 01:02:02AM +0200, Daniel Phillips wrote:
> What I'm really talking about is how you'd reimplement copy_page_range,
> zap_page_range, and the other 4-5 primitives that use the 3 nested loops
> style of traversing the i86-style page table structure.

Why reimplement when you can rename? =)

These guys aren't really the culprits. By and large the pagetables are
just overused and overexposed; things that aren't speed critical should
probably just pass callbacks into a generic walker if they absolutely
have to walk pagetables. i.e. if you aren't the VM, don't do this.
Walking pagetables is horribly slow anyway, zap_page_range() has
ridiculous latencies. Shoving these guys off into their own module
would likely be enough for the moment.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
