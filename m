Date: Tue, 30 Jul 2002 10:39:35 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: severely bloated slabs
Message-ID: <649629297.1028025550@[10.10.2.3]>
In-Reply-To: <20020730172341.GD29537@holomorphy.com>
References: <20020730172341.GD29537@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 132MB of ZONE_NORMAL on a 16GB i386 box tied up in buffer_head slabs
> when all of 3% of it is in use gives me the willies. Periodic slab
> pruning anyone? Might be useful in addition to slab-in-lru.

As long as we give this up under memory pressure, why does this
matter?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
