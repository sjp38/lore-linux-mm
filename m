Date: Wed, 24 May 2006 12:01:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [5/5] move_pages: 32bit support (i386,x86_64 and ia64)
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0605241159110.17801@schroedinger.engr.sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 May 2006, Luck, Tony wrote:

> Any thoughts on the timeline for this?  Is Dec 31, 2006 too soon?
> (or not soon enough!?).

If it does not work then remove it now. Are there any users left?

I vaguely remember some BIOS code having to be executed in ia32 mode in 
order to make some device drives work?

If that is the case then we cannot drop ia32 support at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
