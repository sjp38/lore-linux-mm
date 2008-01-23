From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86 II
Date: Wed, 23 Jan 2008 14:48:09 +0100
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <200801231215.56741.andi@firstfloor.org> <20080123112436.GF21455@csn.ul.ie>
In-Reply-To: <20080123112436.GF21455@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801231448.09514.andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Wednesday 23 January 2008 12:24:36 Mel Gorman wrote:
> On (23/01/08 12:15), Andi Kleen didst pronounce:
> > Anyways from your earlier comments it sounds like you're trying to add
> > SRAT parsing to CONFIG_NUMAQ. Since that's redundant with the old
> > implementation it doesn't sound like a very useful thing to do.
>
> No, that would not be useful at all as it's redundant as you point out. The
> only reason to add it is if the Opteron box can figure out the CPU-to-node
> affinity. 

Assuming srat_32.c was fixed to not crash on Opteron it would likely
do that already without further changes.

> :| The patches applied so far are about increasing test coverage, not SRAT
> messing. 

Test coverage of the NUMAQ kernel?

If you wanted to increase test coverage of 32bit NUMA kernels the right
strategy would be to fix srat_32.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
