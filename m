Date: Mon, 5 Mar 2001 17:50:01 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: Shared mmaps
Message-ID: <20010305175001.P1865@parcelfarce.linux.theplanet.co.uk>
References: <20010304211053.F1865@parcelfarce.linux.theplanet.co.uk> <20010305115219.A573@fred.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010305115219.A573@fred.local>; from ak@muc.de on Mon, Mar 05, 2001 at 11:52:19AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 05, 2001 at 11:52:19AM +0100, Andi Kleen wrote:
> With some extensions I would also find it useful for x86-64 for the 32bit
> mmap emulation (currently it's using a current-> hack)
> For that flags would need to be passed to TASK_UNMAPPED_BASE.

Don't you simply check current->personality to determine whether or not
this is a 32-bit task?

get_unmapped_area is already (optionally) an arch-specific function, so
you can make all the changes you need to that function.

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
