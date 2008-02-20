Date: Wed, 20 Feb 2008 14:21:37 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080219225733.37c56eb2.pj@sgi.com>
References: <20080220114317.642F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080219225733.37c56eb2.pj@sgi.com>
Message-Id: <20080220141329.6435.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

> Did those jobs share nodes -- sometimes two or more jobs using the same
> nodes?  I am sure SGI has such users too, though such job mixes make
> the runtimes of specific jobs less obvious, so customers are more
> tolerant of variations and some inefficiencies, as they get hidden in
> the mix.

Hm
our dedicated ndoe user set memory limit to machine physical memory
size (minus a bit).

I think don't have so much share/dedicate and watch user-defined/swap.
am i misundestand?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
