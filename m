Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Tue, 31 Jul 2001 16:13:24 +0200
References: <Pine.LNX.4.33L.0107292021480.11893-100000@imladris.rielhome.conectiva> <85vG$i31w-B@khms.westfalen.de>
In-Reply-To: <85vG$i31w-B@khms.westfalen.de>
MIME-Version: 1.0
Message-Id: <01073116132401.00303@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kai Henningsen <kaih@khms.westfalen.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 31 July 2001 09:30, Kai Henningsen wrote:
> riel@conectiva.com.br (Rik van Riel)  wrote on 29.07.01 in 
<Pine.LNX.4.33L.0107292021480.11893-100000@imladris.rielhome.conectiva>:
> > On Sun, 29 Jul 2001, Hugh Dickins wrote:
> > > On Sun, 29 Jul 2001, Daniel Phillips wrote:
> > > > "Age" is hugely misleading, I think everybody agrees,
> >
> > Yup. I mainly kept it because we called things this way
> > in the 1.2, 1.3, 2.0 and 2.1 kernels.
> >
> > > > That said, I think BSD uses "weight".
> > >
> > > That's much _much_ better: I'd go for "warmth" myself,
> >
> > FreeBSD uses act_count, short for activation count.
> >
> > Showing how active a page is is probably a better analogy
> > than the temperature one ... but that's just IMHO ;)
>
> Well, people do sometimes speak of "hot" pages (or spots) ... and
> there are no good verbs associated with "activation count". Oh, and
> you might say "the situation heats up" in case of increasing memory
> pressure.
>
> And remember that in physics, temperature (at least in the cases
> where it's used by non-physicists) does measure something
> approximately like average particle velocity, which some
> (non-physicist) people might well call "activity".

Temperature also captures the idea of gradual decay.  Activity sounds 
fine too, both are way better than age.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
