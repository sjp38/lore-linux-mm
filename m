Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080704.135258.255741026.davem@davemloft.net>
References: <20080704.133721.98729739.davem@davemloft.net>
	 <20080704134208.6c712031@infradead.org>
	 <1215204218.3189.8.camel@shinybook.infradead.org>
	 <20080704.135258.255741026.davem@davemloft.net>
Content-Type: text/plain
Date: Fri, 04 Jul 2008 22:05:55 +0100
Message-Id: <1215205555.3189.22.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: arjan@infradead.org, jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-04 at 13:52 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Fri, 04 Jul 2008 21:43:38 +0100
> 
> > He must do. After all, I was working for Red Hat when I started on
> > cleaning up these drivers.
> 
> Then I hope you've caught the e100 ucode in your changes, for
> the sake of full transparency :-)

Yes, I have. I sincerely hope that patch was posted for review;
certainly it _should_ have been. If not, I apologise. It's in
linux-next.

But as I said, I've stopped working on drivers/net/ for now; we're
concentrating on the rest of the kernel where the maintainers are
_happy_ to be brought up to date.

The intention was always that this set of patches should be obviously
correct and uncontentious, without inflaming the religious nutters on
_either_ side of the debate. The fact that there that the most vocal of
the fanatics on _both_ sides are flaming about the sensible middle
ground, where I'm just consolidating what has been common practice for
ages _anyway_, is rather bemusing to me...

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
