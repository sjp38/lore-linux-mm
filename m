Date: Sat, 9 Feb 2008 11:43:29 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-ID: <20080209114329.68820224@bree.surriel.com>
In-Reply-To: <2f11576a0802090833h7a600ee8x87edb423cbbb5d79@mail.gmail.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	<B846E82A-D513-40CD-A19C-B60653569269@jonmasters.org>
	<2f11576a0802090833h7a600ee8x87edb423cbbb5d79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jon Masters <jonathan@jonmasters.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

On Sun, 10 Feb 2008 01:33:49 +0900
"KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Where is the netlink interface? Polling an FD is so last century :)
> 
> to be honest, I don't know anyone use netlink and why hope receive
> low memory notify by netlink.
> 
> poll() is old way, but it works good enough.

More importantly, all gtk+ programs, as well as most databases and other
system daemons have a poll() loop as their main loop.

A file descriptor fits that main loop perfectly.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
