Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080704.133721.98729739.davem@davemloft.net>
References: <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <20080704.133721.98729739.davem@davemloft.net>
Content-Type: text/plain
Date: Fri, 04 Jul 2008 21:53:47 +0100
Message-Id: <1215204827.3189.13.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-04 at 13:37 -0700, David Miller wrote:
> And for one, I have consistently argued that this "best practice" is
> the "worst practice" from a technical perspective.  It is the worst
> because it means mistakes are possible to make between driver and
> firmware versions.  Even with versioning it is not fool proof.
> Whereas if you link the firmware into the driver, it's impossible to
> get wrong.

And you've been wrong about that from the start, which is why the rest
of the kernel has moved on while the drivers you control are left
behind.

But we've already stopped working on drivers/net; we're fixing the rest
of the older drivers first. And every affected maintainer except you and
Jeff seems _happy_ to see their drivers being brought up to date.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
