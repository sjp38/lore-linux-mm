Date: Fri, 7 Jan 2005 10:53:00 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: page migration patchset
Message-ID: <20050106235300.GC14239@krispykreme.ozlabs.ibm.com>
References: <Pine.LNX.4.44.0501052008160.8705-100000@localhost.localdomain> <41DC7EAD.8010407@mvista.com> <20050106144307.GB59451@muc.de> <20050106223046.GB9636@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050106223046.GB9636@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andi Kleen <ak@muc.de>, Steve Longerbeam <stevel@mvista.com>, Hugh Dickins <hugh@veritas.com>, Ray Bryant <raybry@sgi.com>, Christoph Lameter <clameter@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, andrew morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> The second is zero bugfixing or cross-architecture testing activity
> apart from my own. This and the first in conjunction cast serious
> doubt upon and increase the need for heavy critical examination of
> so-called ``consolidation'' patches.

OK lets get moving on the bug fixing. I know of one outstanding hugetlb
bug which is the one you have been working on.

Can we have a complete bug report on it so the rest of us can try to assist?

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
