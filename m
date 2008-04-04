From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC 02/22] x86: Use generic show_mem()
Date: Fri, 4 Apr 2008 10:17:31 +0200
Message-ID: <20080404081731.GA31261@elte.hu>
References: <12071688283927-git-send-email-hannes@saeurebad.de> <12071688511076-git-send-email-hannes@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758311AbYDDIVr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <12071688511076-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


* Johannes Weiner <hannes@saeurebad.de> wrote:

> -config HAVE_ARCH_SHOW_MEM
> -	def_bool y

> -void show_mem(void)
> -{

nice work!

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
