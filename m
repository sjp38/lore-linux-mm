Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Date: Wed, 6 Oct 2004 22:22:20 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@aracnet.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>Because pfn_valid() often returns 0 in inner loop of free_pages_bulk(),
>I want to avoid page fault caused by using get_user() in pfn_valid().

How often?  Surely this is only a problem at the edges of blocks
of memory?  I suppose it depends on whether your discontig memory
appears in blocks much smaller than MAXORDER.  But even there it
should only be an issue coalescing buddies that are bigger than
the granule size (since all of the pages in a granule on ia64 are
guaranteed to exist, the buddy of any page must also exist).

Do you have some data to show that this is a problem.

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
