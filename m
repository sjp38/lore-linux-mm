Message-ID: <39638BD1.20ECAEB3@norran.net>
Date: Wed, 05 Jul 2000 21:26:09 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: User mode stalls - can it be...?
References: <3962874A.190AAC7E@norran.net> <39628F72.4987A36@norran.net> <20000705143519.D1290@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, Jul 05, 2000 at 03:29:22AM +0200, Roger Larsson wrote:
> >
> > static void sync_page_buffers(struct buffer_head *bh, int wait)
> > {
> >       struct buffer_head * tmp = bh;
> >
> >       do {
> >               struct buffer_head *p = tmp;
> >               tmp = tmp->b_this_page;
> >               if (!buffer_locked(p) &&
> >                     buffer_dirty(p))
> >                       ll_rw_block(WRITE, 1, &p);
> >               if (wait)
> >                       __wait_on_buffer(p);
> >       } while (tmp != bh);
> 
> Yikes no.  That will make the syncer wait for every single write
> synchronously.  It will cause a page full of 1k buffers to be written
> out as four separate 1k writes instead of being streamed.  This will
> _kill_ performance.
> 
> Cheers,
>  Stephen


Well, 'wait' is not set at each call...

But I agree that it was not a wery bright idea...
(I am more awake now :-)

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
