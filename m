Date: Tue, 14 May 2002 09:30:12 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] iowait statistics
In-Reply-To: <3CE073FA.57DAC578@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0205140929230.32261-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 May 2002, Andrew Morton wrote:

> > ===== fs/buffer.c 1.64 vs edited =====
> > --- 1.64/fs/buffer.c    Mon May 13 19:04:59 2002
> > +++ edited/fs/buffer.c  Mon May 13 19:16:57 2002
> > @@ -156,8 +156,10 @@
> >         get_bh(bh);
> >         add_wait_queue(&bh->b_wait, &wait);
> >         do {
> > +               atomic_inc(&nr_iowait_tasks);
> >                 run_task_queue(&tq_disk);
> >                 set_task_state(tsk, TASK_UNINTERRUPTIBLE);
> > +               atomic_dec(&nr_iowait_tasks);
> >                 if (!buffer_locked(bh))
> >                         break;
> >                 schedule();
>
> Shouldn't the atomic_inc cover the schedule()?

DOH, indeed.  Placed in the wrong place ;/

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
