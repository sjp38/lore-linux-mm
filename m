From: Andi Kleen <ak@suse.de>
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Date: Thu, 25 May 2006 05:30:59 +0200
References: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com> <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605250531.00108.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, debian-ia64@lists.debian.org
List-ID: <linux-mm.kvack.org>

> I'm a bit worried about this.  As I understand it, the Intel
> software emulator is not open-source.  There may be distros
> like Debian and customer environments where that's not a viable
> alternative.
> 
> If we remove CONFIG_IA32_SUPPORT, every ia64 box will require
> the Intel emulator (or QEMU or some other ill-defined solution)
> in order to run ia32 code, even though every processor in the
> field today supports ia32 in hardware.
> 
> It doesn't feel right to me to remove functionality from machines
> in the field and offer only a proprietary alternative.

You could just freeze the code down to "security fixes only". 
This means new system calls wouldn't need to be added and most programs
fallback if they don't see the latest and great syscalls anyways.
On the other hand it is usually not very hard to add new syscalls
and most of the other code is shared now anyways.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
