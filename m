Message-ID: <486EF2EA.9060903@garzik.org>
Date: Sat, 05 Jul 2008 00:04:58 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215177044.10393.743.camel@pmac.infradead.org>	 <486E2260.5050503@garzik.org>	 <1215178035.10393.763.camel@pmac.infradead.org>	 <20080704.133721.98729739.davem@davemloft.net> <1215204827.3189.13.camel@shinybook.infradead.org>
In-Reply-To: <1215204827.3189.13.camel@shinybook.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> But we've already stopped working on drivers/net; we're fixing the rest
> of the older drivers first. And every affected maintainer except you and
> Jeff seems _happy_ to see their drivers being brought up to date.

Disliking breakage != unhappy at driver change

Since you apparently still do not see the difference between a 
breakage-filled path to goodness, and goodness itself.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
