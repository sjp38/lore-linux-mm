Date: Tue, 30 Jul 2002 10:53:39 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: severely bloated slabs
Message-ID: <20020730175339.GF29537@holomorphy.com>
References: <20020730172341.GD29537@holomorphy.com> <649629297.1028025550@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <649629297.1028025550@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> 132MB of ZONE_NORMAL on a 16GB i386 box tied up in buffer_head slabs
>> when all of 3% of it is in use gives me the willies. Periodic slab
>> pruning anyone? Might be useful in addition to slab-in-lru.

On Tue, Jul 30, 2002 at 10:39:35AM -0700, Martin J. Bligh wrote:
> As long as we give this up under memory pressure, why does this
> matter?

Mostly a question of response time and long idle times being a good
indicator of upcoming workload shifts. I'd say it's behaving as
designed, but not as desired.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
