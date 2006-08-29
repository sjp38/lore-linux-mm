Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC][PATCH 10/10] convert the "easy" architectures to generic PAGE_SIZE
Date: Tue, 29 Aug 2006 14:06:09 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A728D28@scsmsx411.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

> Note that, as promised, this removes ARCH_GENERIC_PAGE_SIZE
> introduced by the first patch in this series.  It is no longer
> needed as _all_ architectures now use this infrastructure.

Either I goofed when applying these patches, or you missed one
in mm/Kconfig.  The version I ended up with had the "Kernel Page Size"
choice still "depends on ARCH_GENERIC_PAGE_SIZE" ... so make
menuconfig didn't let me choose the page size.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
