Received: from dl5rb.ham-radio-op.net (localhost [127.0.0.1])
	by oss.sgi.com (8.12.11.20060308/8.12.11/SuSE Linux 0.7) with ESMTP id m3GHUIk3008920
	for <linux-mm@kvack.org>; Wed, 16 Apr 2008 10:30:18 -0700
Date: Wed, 16 Apr 2008 18:30:48 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [RFC][patch 5/5] mm: Move bootmem descriptors definition to a
	single place
Message-ID: <20080416173048.GB32263@linux-mips.org>
References: <20080416113629.947746497@skyscraper.fehenstaub.lan> <20080416113719.539500813@skyscraper.fehenstaub.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080416113719.539500813@skyscraper.fehenstaub.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Richard Henderson <rth@twiddle.net>, Russell King <rmk@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Hirokazu Takata <takata@linux-m32r.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Kyle McMartin <kyle@parisc-linux.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 16, 2008 at 01:36:34PM +0200, Johannes Weiner wrote:

> There are a lot of places that define either a single bootmem
> descriptor or an array of them.  Use only one central array with
> MAX_NUMNODES items instead.
> 
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
