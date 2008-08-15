Date: Fri, 15 Aug 2008 18:30:20 +0200
Subject: Re: sparsemem support for mips with highmem
Message-ID: <20080815163020.GA9554@alpha.franken.de>
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com> <20080815080331.GA6689@alpha.franken.de> <1218815299.23641.80.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1218815299.23641.80.camel@nimitz>
From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: C Michael Sundius <Michael.sundius@sciatl.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 15, 2008 at 08:48:19AM -0700, Dave Hansen wrote:
> My guess would be that Michael knew that his 32-bit MIPS platform only
> ever has 2GB of memory.

that's the point, which isn't quite correct. It's possible for
a 32bit MIPS system to address 4GB of memory (minus IO). That's
one case where the 31bits don't fit, the other case is a 64bit CPU
running a 32 bit kernel (CONFIG_64BIT selects whether it's a 32bit or
64bit kernel). I'm not whether it's worth to cover both cases, but it's
more restrictive than it's without that change.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
