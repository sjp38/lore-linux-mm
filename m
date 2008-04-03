From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC 10/22] m68k: Use generic show_mem()
Date: Thu, 03 Apr 2008 17:10:21 +0200
Message-ID: <87wsnfnfdu.fsf@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
	<1207168941186-git-send-email-hannes@saeurebad.de>
	<Pine.LNX.4.64.0804030939320.9848@anakin>
	<87myobp02g.fsf@saeurebad.de>
	<Pine.LNX.4.64.0804031538150.11898@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759098AbYDCPKj@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804031538150.11898@anakin> (Geert Uytterhoeven's
	message of "Thu, 3 Apr 2008 15:39:16 +0200 (CEST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sourceforge.net, takata@linux-m32r.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com, akpm@linux-foundation.org
List-Id: linux-mm.kvack.org

Hi,

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> So I suggest to add an additional (first) step to the consolidation: remove all
> duplicates.

I shall do that.  Problem is, I had a patch-series removing only parts
of the duplication (shame on me) and not all of these patches are yet in
the subsystem trees and still partially in -mm.  None of them have hit
mainline yet.  Suggestions?

The earlier patch-series was called `remove redundant output from
show_mem()'.

Sorry for the wasted time.  These cleanups already took more energy than
they are worth it, I guess... :/

	Hannes
