Date: Fri, 04 Jul 2008 13:52:58 -0700 (PDT)
Message-Id: <20080704.135258.255741026.davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Miller <davem@davemloft.net>
In-Reply-To: <1215204218.3189.8.camel@shinybook.infradead.org>
References: <20080704.133721.98729739.davem@davemloft.net>
	<20080704134208.6c712031@infradead.org>
	<1215204218.3189.8.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 04 Jul 2008 21:43:38 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: dwmw2@infradead.org
Cc: arjan@infradead.org, jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> He must do. After all, I was working for Red Hat when I started on
> cleaning up these drivers.

Then I hope you've caught the e100 ucode in your changes, for
the sake of full transparency :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
