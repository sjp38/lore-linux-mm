Date: Mon, 24 Mar 2008 14:46:29 -0700 (PDT)
Message-Id: <20080324.144629.137399000.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE5B88C@orsmsx424.amr.corp.intel.com>
References: <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
	<1FE6DD409037234FAB833C420AA843ECE5B88C@orsmsx424.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 24 Mar 2008 14:25:11 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: tony.luck@intel.com
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> When memory capacity is measured in hundreds of GB, then
> a larger page size doesn't look so ridiculous.

We have hugepages and such for a reason.  And this can be
made more dynamic and flexible, as needed.

Increasing the page size is a "stick your head in the sand"
type solution by my book.

Especially when you can make the hugepage facility stronger
and thus get what you want without the memory wastage side
effects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
