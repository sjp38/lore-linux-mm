Message-ID: <39C7D906.1AF31515@norran.net>
Date: Tue, 19 Sep 2000 23:22:14 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: Rik's VM contains a deadlock somewhere
References: <Pine.LNX.4.21.0009190720440.22122-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Anton Petrusevich <improvisus@echo.ru>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,


I too tested to stress the new VM
Quintelas mmap002 "deadlocks" for me.
PPro, 96 MB, UP

active: 22337 (I think this varies, have too lock a 2nd time)
inactive_dirty: 324 varies
inactive_clean: 0
free: 288
... 1x 512 = 512 kB
... 2 x 16 + 1 x 32 + 1 x 64 = 640 kB

My feeling when looking at Alt-SysRq-M was
that pages was moved between Active and
idle_dirty - will look into this.

There is no 'if (current->need_resched) schedule()'
in this code - if kswapd starts too loop...


PS
 Now I am back from my vacation period...
DS


Rik van Riel wrote:
> 
> On Tue, 19 Sep 2000, Anton Petrusevich wrote:
> 
> > please, check carefully Rik's VM patch, it definitly contains a
> > deadlock, which can be seen on low-memory computers. Try mem=8m. I
> > wasn't able to use any Rik patch since against -test8 (-t8-vmpatch{2,4},
> > -test9-pre{1,2}). It boots fine(mem=16m), but then stalls begin for some
> > time and for infinitive time at last. I told Rik about it, he tried to
> > fix but wasn't successful.
> >
> > With mem=8m it couldn't finish init scripts even.
> 
> I /thought/ I had fixed this, since the system runs fine
> on my (SMP, SCSI) test machine when I boot it with mem=8m.
> 
> Somebody on IRC suggested to me that this may be an UP-only
> bug ... I'm looking into this and hope to fix it soon, but
> I have to admit some help would be welcome ;)
> 
> (I'm still at Linux Kongress and won't be back in the office
> for about a week)
> 
> regards,
> 
> Rik
> --
> "What you're running that piece of shit Gnome?!?!"
>        -- Miguel de Icaza, UKUUG 2000
> 
> http://www.conectiva.com/               http://www.surriel.com/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> Please read the FAQ at http://www.tux.org/lkml/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
