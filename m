Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 68CD46B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 10:43:53 -0500 (EST)
Received: by eaaa11 with SMTP id a11so1701967eaa.14
        for <linux-mm@kvack.org>; Mon, 30 Jan 2012 07:43:51 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCHv19 00/15] Contiguous Memory Allocator
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <201201261531.40551.arnd@arndb.de>
 <20120127162624.40cba14e.akpm@linux-foundation.org>
 <20120130132512.GO25268@csn.ul.ie>
Date: Mon, 30 Jan 2012 16:43:49 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v8wlzbc53l0zgt@mpn-glaptop>
In-Reply-To: <20120130132512.GO25268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
Cc: Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Jonathan
 Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Mon, 30 Jan 2012 14:25:12 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> I reviewed the core MM changes and I've acked most of them so the
> next release should have a few acks where you expect them. I did not
> add a reviewed-by because I did not build and test the thing.

Thanks!

I've either replied to your comments or applied suggested changes.
If anyone cares, not-tested changes are available at
	git://github.com/mina86/linux-2.6.git cma

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
