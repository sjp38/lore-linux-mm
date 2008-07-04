Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080704135901.51b6b6e2@linux.intel.com>
References: <1215178035.10393.763.camel@pmac.infradead.org>
	 <20080704.133721.98729739.davem@davemloft.net>
	 <20080704134208.6c712031@infradead.org>
	 <20080704.135150.250580915.davem@davemloft.net>
	 <20080704135901.51b6b6e2@linux.intel.com>
Content-Type: text/plain
Date: Fri, 04 Jul 2008 22:12:03 +0100
Message-Id: <1215205923.3189.28.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-04 at 13:59 -0700, Arjan van de Ven wrote:
> On Fri, 04 Jul 2008 13:51:50 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> > Yet that is exactly the impression that I have gotten over
> > all of the communication I've received.
> > 
> 
> then I'd like to set that impression straight (and burry the
> conspiracy theories)... I've never asked David to do this for any kind
> of legal theory or otherwise. Any of it, tg3 or otherwise. And while I
> can't speak for Intel on legal aspects (if there are any here), I can
> speak as Davids manager that this entire project hasn't originated from
> anything we (Intel) asked him to do.

I wouldn't worry, Arjan. There is no basis for Dave's claim, and he
knows perfectly well I was working on it before I was working for Intel.

It's perfectly sensible janitorial-type work which has needed doing for
ages, and which I got interested in after a discussion about the kernel
that Fedora ships.

The Fedora Engineering Steering Committee (of which I'm a member) agreed
that Fedora would _like_ to ship a firmware-less kernel, if that was
technically feasible (and didn't involve actually breaking drivers).

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
