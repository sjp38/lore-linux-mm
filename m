Subject: Re: [Lhms-devel] new memory hotremoval patch
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040630111719.EBACF70A92@sv1.valinux.co.jp>
References: <20040630111719.EBACF70A92@sv1.valinux.co.jp>
Content-Type: text/plain
Message-Id: <1088640671.5265.1017.camel@nighthawk>
Mime-Version: 1.0
Date: Wed, 30 Jun 2004 17:11:11 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-06-30 at 04:17, IWAMOTO Toshihiro wrote:
> Due to struct page changes, page->mapping == NULL predicate can no
> longer be used for detecting cancellation of an anonymous page
> remapping operation.  So the PG_again bit is being used again.
> It may be still possible to kill the PG_again bit, but the priority is
> rather low.

But, you reintroduced it everywhere, including file-backed pages, not
just for anonymous pages?  Why was this necessary?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
