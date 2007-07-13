Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 0/7] Sparsemem Virtual Memmap V5
Date: Fri, 13 Jul 2007 15:37:47 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A01EA65B9@scsmsx411.amr.corp.intel.com>
In-Reply-To: <Pine.LNX.4.64.0707131510350.25753@schroedinger.engr.sgi.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> How many tests were done and on what platform?

Andy's part 0/7 post starts off with the performance numbers.  He
didn't say which ia64 platform was used for the tests.

Looking my logs for the last few kernel builds (some built on a
tiger_defconfig kernel which uses CONFIG_VIRTUAL_MEM_MAP=y, and
some with the new CONFIG_SPARSEMEM_VMEMMAP) I'd have a tough time
saying whether there was a regression or not).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
