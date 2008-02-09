Received: by qb-out-0506.google.com with SMTP id e21so6835328qba.0
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 08:49:42 -0800 (PST)
Message-ID: <2f11576a0802090849h1599c4a9jc21bf21c9e7cd947@mail.gmail.com>
Date: Sun, 10 Feb 2008 01:49:41 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080209114329.68820224@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	 <B846E82A-D513-40CD-A19C-B60653569269@jonmasters.org>
	 <2f11576a0802090833h7a600ee8x87edb423cbbb5d79@mail.gmail.com>
	 <20080209114329.68820224@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Jon Masters <jonathan@jonmasters.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

Hi Rik

> More importantly, all gtk+ programs, as well as most databases and other
> system daemons have a poll() loop as their main loop.

not only gtk+, may be all modern GUI program :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
