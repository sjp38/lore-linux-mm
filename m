Message-Id: <200112211155.fBLBtC426481@mailb.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [RFC] Concept: Active/busy "reverse" mapping
Date: Fri, 21 Dec 2001 12:52:23 +0100
References: <Pine.LNX.4.33L.0112200121290.15741-100000@imladris.surriel.com> <200112210107.fBL17nL10142@maild.telia.com> <20011220204524.K6276@redhat.com>
In-Reply-To: <20011220204524.K6276@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fridayen den 21 December 2001 02.45, Benjamin LaHaise wrote:
> On Fri, Dec 21, 2001 at 02:05:26AM +0100, Roger Larsson wrote:
> > The goal of this code is to make sure that used pages are marked as such.
> >
> > This is accomplished by:
> >
> > * When a process is descheduled - look in its mm for used pages - update
> > corresponding page. (Done at most once per tick)
>
> Interesting.  The same effect is acheived by the reverse mapping code on
> a global scale while addressing the issue of how to figure out what extent
> memory pressure is needed on the page tables.
>
> 		-ben

There are other ways too...
Link all used mm:s and check them with kswapd...
etc... etc...

It should be possible to optimize away most performance problems...

/RogerL

PS
  I will be away for some days...
DS

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
