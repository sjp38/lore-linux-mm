Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 0/3] NUMA boot hash allocation interleaving
Date: Tue, 14 Dec 2004 10:32:20 -0800
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F028C1639@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

>this behavior is turned on by default only for IA64 NUMA systems

>A boot line parameter "hashdist" can be set to override the default
>behavior.


Note to node hot-plug developers ... if this patch goes in you
will also want to disable this behaviour, otherwaise all nodes
become non-removeable (unless you can transparently re-locate the
physical memory backing all these tables).

-Tony
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
