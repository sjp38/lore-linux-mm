Date: Fri, 15 Aug 2008 18:33:02 +0200
Subject: Re: sparsemem support for mips with highmem
Message-ID: <20080815163302.GA9846@alpha.franken.de>
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com> <20080815080331.GA6689@alpha.franken.de> <1218815299.23641.80.camel@nimitz> <48A5AADE.1050808@sciatl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A5AADE.1050808@sciatl.com>
From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 15, 2008 at 09:12:14AM -0700, C Michael Sundius wrote:
> yes,  actually the top two bits are used in MIPS as segment bits.

you are confusing virtual addresses with physcial addresses. There
are even 32bit CPU, which could address more than 4GB physical
addresses via TLB entries.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
