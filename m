Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [5/5] move_pages: 32bit support (i386,x86_64 and ia64)
Date: Wed, 24 May 2006 12:18:27 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F0693FCE7@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> If it does not work then remove it now.
It still works ... it just isn't complete as most of the syscalls
added in the past 18 months haven't been included.

> Are there any users left?
I've no idea.  Two OSDs have been shipping the Intel s/w emulator for
a while now, one installs it by default.  So the number of users is
probably diminishing.  When people upgrade to Montecito, s/w emulation
is the only option, which will further reduce the user population.

> I vaguely remember some BIOS code having to be executed in ia32 mode in 
> order to make some device drives work?
> If that is the case then we cannot drop ia32 support at all.
The kernel doesn't handle BIOS code execution ... so the value of
CONFIG_IA32_SUPPORT makes no difference to this.

-Tony

If this thread continues, I'll drop all the innocent bystanders from
the Cc: list and just leave linux-ia64 from future replies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
