Content-Type: text/plain;
  charset="utf-8"
From: Jordi Polo <mumismo@wanadoo.es>
Subject: Re: Consistent page aging....
Date: Sat, 28 Jul 2001 01:45:52 +0200
References: <Pine.LNX.4.21.0107260701290.3707-100000@freak.distro.conectiva> <m166cfg33u.fsf@frodo.biederman.org>
In-Reply-To: <m166cfg33u.fsf@frodo.biederman.org>
MIME-Version: 1.0
Message-Id: <01072801455200.04092@mioooldpc>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

El Jueves 26 Julio 2001 16:46, escribiste:
> Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> > On 25 Jul 2001, Eric W. Biederman wrote:
> > > Be very clear on this because I sense some confusion.  We don't
> > > ``require'' allocation of swap space to do aging.
> >
> > Right now, we have to make anon pages become swap cache pages (which need
> > swap space allocated) to be able to age them in the LRU lists.
>
> Nothing important in the aging algorithm on the active list requires
> that the page be in the page cache.  The only immediate difference is
> that the test to see if a page is busy needs to be updated to not
> assume the page is in the page cache.
>
> > Sure, we do aging before by just scanning the pte's and the process of
> > adding a page to the swapcache is already some kind of aging.
> >
> > I'm talking about the aging in the LRU lists here.
>
> Me to.
>
> > There is no confusion. Its the way 2.4 VM works.
>
> It is a minor implemtation detail of the 2.4 VM not a fundamental
> property.  If fundamental routines like add_to_page_cache didn't make
> the assumption that a page they are being called on wasn't on an lru
> list it might be straight forward to change.   But as it is you have
> to be very careful to make that kind of change.
>
> > See?
>
> Nope.
>

if i undestood it :
we need the page in pagecache to be aged , so if they are anon, we have to 
give then swap. We have two effects that maybe not desirable:
1.- allocate swap space for active_list pages? makes sense?
2.- a very different way to scan anon and no anon pages.

What about (surely crazy idea) make the list anon page aware, so they make 
aging in anon and pagecache with no difference. When you move a page to 
inactive_dirty you can allocate space in swap if necesary so you avoid having 
a swap space for all that active_list pages .

easier to say that implement

--
Jordi

    
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
