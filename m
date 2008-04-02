From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC 00/21] Generic show_mem()
Date: Wed, 2 Apr 2008 14:53:45 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843ECF9DFC4@orsmsx424.amr.corp.intel.com>
References: <12071682142640-git-send-email-hannes@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932287AbYDBVzj@vger.kernel.org>
Content-class: urn:content-classes:message
In-reply-to: <12071682142640-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@saeurebad.de>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk
List-Id: linux-mm.kvack.org

> Tony, as far as I understand, ia64 jumps holes in the memory map with
> vmemmap_find_next_valid_pfn().  Any idea if and how this could be
> built into the generic show_mem() version?

Perhaps it might be worth looking at this when ia64 slims down to
just one memory model (using sparse virtual mem map).  But I don't
think anyone is actively working on this.  Right now we have two
very different show_mem() functions for the contig and discontig
cases.

This whole function sends shivers down my spine for a large
system though ... that inner loop looks at every single page
structure ... on a multi-terabyte machine that could run to
billions of cache misses.  Hope the users aren't in a hurry
to see the answer ... or doing something painful like:

	# watch -n 1 cat /proc/meminfo

-Tony
