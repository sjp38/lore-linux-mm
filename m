Message-Id: <200108231849.f7NIns005651@maila.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [PATCH NG] alloc_pages_limit & pages_min
Date: Thu, 23 Aug 2001 20:45:31 +0200
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

A lighter alternative would be to reclaim just one extra page...
Then it will move in the right direction but not more, quite
nice actually!

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
