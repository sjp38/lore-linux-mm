Date: 31 Jul 2001 09:30:00 +0200
From: kaih@khms.westfalen.de (Kai Henningsen)
Message-ID: <85vG$i31w-B@khms.westfalen.de>
References: <Pine.LNX.4.33L.0107292021480.11893-100000@imladris.rielhome.conectiva>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
References: <Pine.LNX.4.33L.0107292021480.11893-100000@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

riel@conectiva.com.br (Rik van Riel)  wrote on 29.07.01 in <Pine.LNX.4.33L.0107292021480.11893-100000@imladris.rielhome.conectiva>:

> On Sun, 29 Jul 2001, Hugh Dickins wrote:
> > On Sun, 29 Jul 2001, Daniel Phillips wrote:
> > >
> > > "Age" is hugely misleading, I think everybody agrees,
>
> Yup. I mainly kept it because we called things this way
> in the 1.2, 1.3, 2.0 and 2.1 kernels.
>
> > > That said, I think BSD uses "weight".
>
> > That's much _much_ better: I'd go for "warmth" myself,
>
> FreeBSD uses act_count, short for activation count.
>
> Showing how active a page is is probably a better analogy
> than the temperature one ... but that's just IMHO ;)

Well, people do sometimes speak of "hot" pages (or spots) ... and there  
are no good verbs associated with "activation count". Oh, and you might  
say "the situation heats up" in case of increasing memory pressure.

And remember that in physics, temperature (at least in the cases where  
it's used by non-physicists) does measure something approximately like  
average particle velocity, which some (non-physicist) people might well  
call "activity".

MfG Kai
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
