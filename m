Date: Wed, 30 Jun 2004 23:33:50 +0900 (JST)
Message-Id: <20040630.233350.74723167.taka@valinux.co.jp>
Subject: Re: [Lhms-devel] Re: new memory hotremoval patch
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <1088595151.2706.12.camel@laptop.fenrus.com>
References: <20040630111719.EBACF70A92@sv1.valinux.co.jp>
	<1088595151.2706.12.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com
Cc: iwamoto@valinux.co.jp, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> > Page "remapping" is a mechanism to free a specified page by copying the
> > page content to a newly allocated replacement page and redirecting
> > references to the original page to the new page.
> > This was designed to reliably free specified pages, unlike the swapout
> > code.
> 
> are you 100% sure the locking is correct wrt O_DIRECT, AIO or futexes ??

Sure, it can handle that!
And it can handle pages on RAMDISK and sysfs and so on.


Thank you,
Hirokazu Takahashi.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
