Message-Id: <200108231841.f7NIf3001564@mailf.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [PATCH NG] alloc_pages_limit & pages_min
Date: Thu, 23 Aug 2001 20:36:39 +0200
References: <Pine.LNX.4.33L.0108222139350.5646-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108222139350.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursdayen den 23 August 2001 02:40, Rik van Riel wrote:
> On Thu, 23 Aug 2001, Roger Larsson wrote:
> > +				if (page) {
> > +					while (z->free_pages < z->pages_low) {
> > +						struct page *extra = reclaim_page(z);
> > +						if (!extra)
> > +							break;
> > +						__free_page(extra);
> > +					}
> > +				}
>
> This is a surprise ;)
>
> Why did you introduce this piece of code?
> What is it supposed to achieve ?
>
f we did get one page => we are above pages_min
try to reach pages_low too.
But holding on to the page we got.

It is possible that it should only be done if we started under
pages_min. But it will be faster the closer we start to pages_low

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
