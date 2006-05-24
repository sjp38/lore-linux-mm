Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [5/5] move_pages: 32bit support (i386,x86_64 and ia64)
Date: Wed, 24 May 2006 11:45:58 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> 2. There is a whole range of syscalls missing for ia64 that I basically
>   interpolated from elsewhere.

I've been thinking of dropping CONFIG_IA32_SUPPORT completely from ia64.
I've heard no complaints that new syscalls are not being added to the
ia32 compat side ... which is an indication that people are not
actively using this.  Some OSDs have been building with this
turned off for a while now (perhaps in preparation for "Montecito"
which no longer has h/w support for the x86 instruction set, or
perhaps because it represnts a huge block of lightly/barely tested
code that will have its share of support issues).

I suppose I should do this by adding an entry to
 Documentation/feature-removal-schedule.txt

Any thoughts on the timeline for this?  Is Dec 31, 2006 too soon?
(or not soon enough!?).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
