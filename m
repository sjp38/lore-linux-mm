Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Sun, 29 Jul 2001 17:34:56 +0200
References: <Pine.LNX.4.33L.0107291147500.11893-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0107291147500.11893-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Message-Id: <01072917345603.00341@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sunday 29 July 2001 16:48, Rik van Riel wrote:
> On Sun, 29 Jul 2001, Daniel Phillips wrote:
> > On Saturday 28 July 2001 22:26, Linus Torvalds wrote:
> > > We only mark the page referenced when we read it, we don't
> > > actually increment the age.
> >
> > For already-cached pages we have:
> >
> >    do_generic_file_read->__find_page_nolock->age_page_up
>
> s/have/had/
>
> This was changed quite a while ago.

Yes, correct.  (Should teach me not to rely on a 2.4.2 tree for my 
cross-reference.)  Hmm, so now age_page_up is unused and 
age_page_up_nolock is called from just one place, refill_inactive_scan. 
The !age test still doesn't make sense.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
