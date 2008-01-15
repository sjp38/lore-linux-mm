Date: Tue, 15 Jan 2008 11:20:27 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
Message-ID: <20080115112027.6120915b@lxorguk.ukuu.org.uk>
In-Reply-To: <20080115195022.11A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080115104619.10dab6de@lxorguk.ukuu.org.uk>
	<20080115195022.11A3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jan 2008 19:59:02 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> > > the core of this patch series.
> > > add /dev/mem_notify device for notification low memory to user process.
> > 
> > As you only wake one process how would you use this API from processes
> > which want to monitor and can free memory under load. Also what fairness
> > guarantees are there...
> 
> Sorry, I don't make sense what you mean fairness.
> Could you tell more?

If you have two processes each waiting on mem_notify is it not possible
that one of them will keep being the one woken up and the other will
remain stuck ?

It also appears there is no way to wait for memory shortages (processes
that can free memory easily) only for memory to start appearing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
