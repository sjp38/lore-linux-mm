Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: larger default page sizes...
Date: Mon, 24 Mar 2008 14:25:11 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843ECE5B88C@orsmsx424.amr.corp.intel.com>
In-reply-to: <20080324.133722.38645342.davem@davemloft.net>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com><20080321.145712.198736315.davem@davemloft.net><Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com> <20080324.133722.38645342.davem@davemloft.net>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>, clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> The memory wastage is just rediculious.

In an ideal world we'd have variable sized pages ... but
since most arcthitectures have no h/w support for these
it may be a long time before that comes to Linux.

In a fixed page size world the right page size to use
depends on the workload and the capacity of the system.

When memory capacity is measured in hundreds of GB, then
a larger page size doesn't look so ridiculous.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
