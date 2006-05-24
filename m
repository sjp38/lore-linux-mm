From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Date: Wed, 24 May 2006 14:38:34 -0600
References: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605241438.34303.bjorn.helgaas@hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, debian-ia64@lists.debian.org
List-ID: <linux-mm.kvack.org>

On Wednesday 24 May 2006 12:45, Luck, Tony wrote:
> I've been thinking of dropping CONFIG_IA32_SUPPORT completely from ia64.
> I've heard no complaints that new syscalls are not being added to the
> ia32 compat side ... which is an indication that people are not
> actively using this.

Or maybe the people using ia32 compatibility are just running big
apps like Firefox or Open Office that are non-trivial to build for
ia64, but may not care as much about shiny new syscalls.

Later, Tony wrote:
> > Are there any users left?
> I've no idea.  Two OSDs have been shipping the Intel s/w emulator for
> a while now, one installs it by default.  So the number of users is
> probably diminishing.  When people upgrade to Montecito, s/w emulation
> is the only option, which will further reduce the user population.

I'm a bit worried about this.  As I understand it, the Intel
software emulator is not open-source.  There may be distros
like Debian and customer environments where that's not a viable
alternative.

If we remove CONFIG_IA32_SUPPORT, every ia64 box will require
the Intel emulator (or QEMU or some other ill-defined solution)
in order to run ia32 code, even though every processor in the
field today supports ia32 in hardware.

It doesn't feel right to me to remove functionality from machines
in the field and offer only a proprietary alternative.

Bjorn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
