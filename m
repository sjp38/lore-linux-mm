Date: Sun, 29 Jul 2001 20:23:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <Pine.LNX.4.21.0107292242170.1279-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33L.0107292021480.11893-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, "Linus Torvalds <torvalds@transmeta.com> Marcelo Tosatti" <marcelo@conectiva.com.br>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Hugh Dickins wrote:
> On Sun, 29 Jul 2001, Daniel Phillips wrote:
> >
> > "Age" is hugely misleading, I think everybody agrees,

Yup. I mainly kept it because we called things this way
in the 1.2, 1.3, 2.0 and 2.1 kernels.

> > That said, I think BSD uses "weight".

> That's much _much_ better: I'd go for "warmth" myself,

FreeBSD uses act_count, short for activation count.

Showing how active a page is is probably a better analogy
than the temperature one ... but that's just IMHO ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
