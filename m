Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Date: Thu, 7 Oct 2004 08:53:32 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F022668D0@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>The normal way to fix the above is just to have a bitmap array 
>to test - in your case a 1GB granularity would be sufficicent. That 
>takes < 1 word to implement for the example above ;-)

In the general case you need a bit for each granule (since that is the
unit that the kernel admits/denies the existence of memory).  But the
really sparse systems end up with a large bitmap.  SGI Altix uses 49
physical address bits, and a granule size of 16MB ... so we need 2^25
bits ... i.e. 4MBbytes.  While that's a drop in the ocean on a 4TB
machine, it still seems a pointless waste.

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
