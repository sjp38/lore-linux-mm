Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <alpine.DEB.1.10.0807061351040.11010@asgard.lang.hm>
References: <1215178035.10393.763.camel@pmac.infradead.org>
	 <486E2818.1060003@garzik.org> <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
	 <20080704.134329.209642254.davem@davemloft.net>
	 <20080704220444.011e7e61@lxorguk.ukuu.org.uk>
	 <alpine.DEB.1.10.0807061311030.11010@asgard.lang.hm>
	 <1215376034.3189.127.camel@shinybook.infradead.org>
	 <alpine.DEB.1.10.0807061351040.11010@asgard.lang.hm>
Content-Type: text/plain
Date: Sun, 06 Jul 2008 21:56:54 +0100
Message-Id: <1215377814.3189.137.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, David Miller <davem@davemloft.net>, jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 2008-07-06 at 13:52 -0700, david@lang.hm wrote:
> On Sun, 6 Jul 2008, David Woodhouse wrote:
> 
> > On Sun, 2008-07-06 at 13:17 -0700, david@lang.hm wrote:
> >> if David W were to make it possible to not use the load_firmware() call to
> >> userspace and build the firmware into the driver (be it in a monolithic
> >> kernel or the module that contains the driver)
> >
> > You _can_ build the firmware into the kernel.
> 
> right, but not into a module. you have half of the answer in place, but 
> not all of it.

The useful half. If you have userspace to load modules, you have
userspace to load firmware too.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
