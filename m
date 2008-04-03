From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC 00/21] Generic show_mem()
Date: Fri, 04 Apr 2008 01:45:59 +0200
Message-ID: <87hceimrig.fsf@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757521AbYDCXqU@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de> (Johannes
	Weiner's message of "Wed, 2 Apr 2008 22:40:06 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

Hi,

most of the feedback I got now was about information displaying that I
allegedly have simply dropped.  This was only true in one case where I
missed the quicklist cache, the other droppings were redundant
information (already displayed in show_free_areas() for example).

Geert suggested that I should boil down show_mem() first for each arch
and then unify it but I would prefer unifying it first and listing
removed redundancy in the changelog of every arch-specific removal. Any
objections on this?

	Hannes
