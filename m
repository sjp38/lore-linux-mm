Date: Wed, 25 Jul 2001 07:11:14 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Consistent page aging....
In-Reply-To: <m1n15tgvyv.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.21.0107250701330.2948-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 25 Jul 2001, Eric W. Biederman wrote:

> Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> 
> > Sorry, Eric.
> >
> > The biggest 2.4 swapping bug is that we need to allocate swap space for a
> > page to be able to age it. 
> 
> Well I guess biggest bug is a debatable title.  
> 
> > We had to be able to age pages without allocating swap space...
> 
> That sounds reasonable.  I haven't been over the aging code lately it
> keeps changing.  You say this hasn't been fixed?  Looking... O.k. I
> see what you are talking about.  
> 
> I don't see any technical reasons why we can't do this.  Doing it
> without adding many extra special cases would require some thinking
> but nothing fundamental says you can't have anonymous pages in the
> active list. 

Right.

> You can't move mapped pages off of the active list but this holds true
> anyway.
> 
> The only benefit this would bring is that after anonymous pages have
> been converted to swappable pages they wouldn't start at the end of
> the active_list.

Right now we have to allocate space on swap for any page which we want to
add to the active list. (so we are able to age the anon pages as other
cache pages)

> I can see how this would be helpful, but unless you benchmark this
> I don't see how this can as the biggest 2.4 swapping bug.

Its the "2xRAM swap rule" problem.

IMO having to allocate swap space to be able to do _aging_ on anonymous
pages is just nonsense.

Now doing the swap allocation at the time we're writting out swap pages
(page_launder()) makes sense for me.

Thats a 2.5 thing, of course...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
