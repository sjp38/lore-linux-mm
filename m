Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: Anticipatory prefaulting in the page fault handler V1
Date: Wed, 8 Dec 2004 09:44:09 -0800
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F02844270@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, nickpiggin@yahoo.com.au
Cc: Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>If a fault occurred for page x and is then followed by page 
>x+1 then it may be reasonable to expect another page fault
>at x+2 in the future.

What if the application had used "madvise(start, len, MADV_RANDOM)"
to tell the kernel that this isn't "reasonable"?

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
