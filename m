Date: Wed, 6 Feb 2002 10:25:34 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: .Help with measuring working-set
In-Reply-To: <20020206100344.A28700@wotan.suse.de>
Message-ID: <Pine.LNX.4.33L.0202061023490.17850-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Suresh Duddi <dp@netscape.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2002, Andi Kleen wrote:
> On Mon, Feb 04, 2002 at 06:21:00PM -0800, Suresh Duddi wrote:

> > http://www.mozilla.org/projects/footprint/footprint-guide.html
> >
> > One thing we are struggling with is measurement of working set of app
> > during a time interval.

> > Any pointers ? Are the metrics the best ones to measure and optimize ?
>
> I guess you would prefer to know which pages are mapped at a given
> point. This would require some custom patching to add a trace facility
> for that. Shouldn't be that hard to implement, but I don't know of a
> ready patch.

I think Mike Shaver (you know him) has made a kernel patch
to measure exacty this, also for Mozilla development.

You should be able to just use his patch, if he still has
it.

regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
