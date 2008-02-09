Received: by qb-out-0506.google.com with SMTP id e21so6828406qba.0
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 08:33:50 -0800 (PST)
Message-ID: <2f11576a0802090833h7a600ee8x87edb423cbbb5d79@mail.gmail.com>
Date: Sun, 10 Feb 2008 01:33:49 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <B846E82A-D513-40CD-A19C-B60653569269@jonmasters.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	 <B846E82A-D513-40CD-A19C-B60653569269@jonmasters.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Masters <jonathan@jonmasters.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

Hi

> Interesting patch series (I am being yuppie and reading this thread
> from my iPhone on a treadmill at the gym - so further comments later).
> I think that this is broadly along the lines that I was thinking, but
> this should be an RFC only patch series for now.

sorry, I fixed at next post.


> Some initial questions:

Thank you.
welcome to any discussion.

> Where is the netlink interface? Polling an FD is so last century :)

to be honest, I don't know anyone use netlink and why hope receive
low memory notify by netlink.

poll() is old way, but it works good enough.

and, netlink have a bit weak point.
end up, netlink philosophy is read/write model.

I afraid to many low-mem message queued in netlink buffer
at under heavy pressure.
it cause degrade memory pressure.


> Still, it is good to start with some code - eventually we might just
> have a full reservation API created. Rik and I and others have bounced
> ideas around for a while and I hope we can pitch in. I will play with
> these patches later.

Great.
Welcome to any idea and any discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
