Subject: Re: Consistent page aging....
References: <Pine.LNX.4.33L.0107251342040.20326-100000@duckman.distro.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 26 Jul 2001 01:19:33 -0600
In-Reply-To: <Pine.LNX.4.33L.0107251342040.20326-100000@duckman.distro.conectiva>
Message-ID: <m1hew0f98a.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 25 Jul 2001, Eric W. Biederman wrote:
> > Rik van Riel <riel@conectiva.com.br> writes:
> 
> > > Except that for - presumably dbench-related ? - reasons
> > > Linus and Davem seem to be vetoeing this change.
> >
> > Hmm.  I haven't seen a patch for it, and I haven't seen the change being
> > vetoed by Linus and Davem.  So I'd have to have more context to comment.
> 
> Me neither. Davem had "thrown away his code" so wasn't able
> (or willing) to tell me exactly what he did. ;(

Well there is a relatively cheap way to prototype the gains by better
aging.  Allocate swap pages in do_anonymous_page.  

That should take about 5 lines, and you can then run benchmarks to see
if the numbers improve.  The pages won't be allocated at exactly the
same space in swap but otherwise the numbers should be the same.

Though this might somehow slow down a fast path and cause problems.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
