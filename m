Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 413516B028F
	for <linux-mm@kvack.org>; Tue,  4 May 2010 14:17:04 -0400 (EDT)
Received: by bwz2 with SMTP id 2so2278688bwz.10
        for <linux-mm@kvack.org>; Tue, 04 May 2010 11:17:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100504174507.GI30601@n2100.arm.linux.org.uk>
References: <k2ncecb6d8f1004191627w3cd36450xf797f746460abb09@mail.gmail.com>
	<20100420155122.6f2c26eb.akpm@linux-foundation.org> <20100420230719.GB1432@n2100.arm.linux.org.uk>
	<n2gcecb6d8f1005041035w51dac3c8ke829a4ae8bf7f408@mail.gmail.com>
	<20100504174507.GI30601@n2100.arm.linux.org.uk>
From: Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>
Date: Tue, 4 May 2010 15:16:40 -0300
Message-ID: <v2gcecb6d8f1005041116wc521061jba732b6a10b0b3e7@mail.gmail.com>
Subject: Re: Suspicious compilation warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, May 4, 2010 at 14:45, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
>
> What should be asked is whether it has been tested - if not, can we find
> someone who can test and validate the change?

I can test it, but I need help to figure out the test itself. I am
porting the kernel 2.6 to nanoengine and my resources in that
environment are still rather limited, not to mention I have not
finished the PCI port, so I still have no network.

On the other hand, the current situation is clearly broken and your
solution can hardly be worse than having NR_SECTION_ROOTS == 0.

Regards,
Marcelo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
