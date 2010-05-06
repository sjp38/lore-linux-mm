Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AE83D6B0277
	for <linux-mm@kvack.org>; Thu,  6 May 2010 09:24:45 -0400 (EDT)
Received: by bwz4 with SMTP id 4so1232205bwz.6
        for <linux-mm@kvack.org>; Thu, 06 May 2010 06:24:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <p2g9c9fda241005051824k54e70136v8324d135b44c71b5@mail.gmail.com>
References: <k2ncecb6d8f1004191627w3cd36450xf797f746460abb09@mail.gmail.com>
	<20100420155122.6f2c26eb.akpm@linux-foundation.org> <20100420230719.GB1432@n2100.arm.linux.org.uk>
	<4BE14335.10702@ru.mvista.com> <p2g9c9fda241005051824k54e70136v8324d135b44c71b5@mail.gmail.com>
From: Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>
Date: Thu, 6 May 2010 10:24:23 -0300
Message-ID: <n2ycecb6d8f1005060624y8ada0c03yc4fab915b3d13a0a@mail.gmail.com>
Subject: Re: Suspicious compilation warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Kyungmin Park <kmpark@infradead.org>
Cc: Sergei Shtylyov <sshtylyov@mvista.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Stephen Rothwell <sfr@canb.auug.org.au>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi Kyungmin,

On Wed, May 5, 2010 at 22:24, Kyungmin Park <kmpark@infradead.org> wrote:
>
> Hi,
>
> It tested with my board and working.
> Just curious. If NR_SECTION_ROOTS is zero and uninitialized then
> what's problem? Since we boot and working without patch.

The original compiler error message was:

mm/sparse.c: In function '__section_nr':
mm/sparse.c:135: warning: 'root' is used uninitialized in this function

Leaving a variable to be used uninitialized is the issue here.

> Thank you,
> Kyungmin Park

Regards,
Marcelo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
