Date: Mon, 24 Mar 2008 13:37:22 -0700 (PDT)
Message-Id: <20080324.133722.38645342.davem@davemloft.net>
Subject: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	<20080321.145712.198736315.davem@davemloft.net>
	<Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 24 Mar 2008 11:27:06 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> The move to 64k page size on IA64 is another way that this issue can
> be addressed though.

This is such a huge mistake I wish platforms such as powerpc and IA64
would not make such decisions so lightly.

The memory wastage is just rediculious.

I already see several distributions moving to 64K pages for powerpc,
so I want to nip this in the bud before this monkey-see-monkey-do
thing gets any more out of hand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
