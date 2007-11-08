Subject: Plans for Onezonelist patch series ???
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1194535612.6214.9.camel@localhost>
References: <20071107011130.382244340@sgi.com>
	 <1194535612.6214.9.camel@localhost>
Content-Type: text/plain
Date: Thu, 08 Nov 2007 11:01:14 -0500
Message-Id: <1194537674.5295.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel [anyone?]

Do you know what the plans are for your "onezonelist" patch series?

Are they going into -mm for, maybe, .25?  Or have they been dropped.  

I carry the last posting in my mempolicy tree--sometimes below my
patches; sometimes above.  Our patches touch some of the same places in
mempolicy.c and require reject resolution when changing the order.  I
can save Andrew some work if I knew that your patches were going to be
in the next -mm by holding off and doing the rebase myself.

Regards,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
