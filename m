Date: Tue, 3 Jun 2008 20:24:13 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
Message-ID: <20080603182413.GJ20824@one.firstfloor.org>
References: <20080603095956.781009952@amd.local0.net> <20080603100939.967775671@amd.local0.net> <1212515282.8505.19.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1212515282.8505.19.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 03, 2008 at 10:48:02AM -0700, Dave Hansen wrote:
> First of all, it seems a bit silly to require that users spell out all
> of the huge page sizes at boot.  Shouldn't we allow the small sizes to
> be runtime-added as well

They are already for most systems where you have only two
hpage sizes. That is because the legacy hpage size is always 
added and you can still allocate pages for it using the sysctl. And if
you want to prereserve at boot you'll have to spell the size out
explicitely anyways.

> 
> Then, give the boot-time large page reservations either to hugepages= or
> a new boot option.  But, instead of doing it in number of hpages, do it
> in sizes like hugepages=10G.  Bootmem-alloc that area, and make it

That assumes you can allocate all 10GB continuously.  Might be not true.
e.g. consider a 16GB x86 with its 1GB PCI memory hole at 4GB and user
wants 14GB worth of hugepages. It would need to allocate over the hole
which is not possible in your scheme.

The bootmem allocator always needs to know the size to be able to split
up.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
