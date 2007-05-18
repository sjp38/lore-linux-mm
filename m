Content-Class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [rfc] increase struct page size?!
Date: Fri, 18 May 2007 13:37:09 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A017BCA67@scsmsx411.amr.corp.intel.com>
In-Reply-To: <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I wonder if there are other uses for the free space?

	unsigned long moreflags;

Nick and Hugh were just sparring over adding a couple (or perhaps 8)
flag bits.  This would supply 64 new bits ... maybe that would keep
them happy for a few more years.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
