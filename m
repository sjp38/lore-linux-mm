Message-ID: <20010927014431.C2164@bug.ucw.cz>
Date: Thu, 27 Sep 2001 01:44:31 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: broken VM in 2.4.10-pre9
References: <20010925005033.A137@bug.ucw.cz> <Pine.LNX.4.21.0109261518520.957-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0109261518520.957-100000@freak.distro.conectiva>; from Marcelo Tosatti on Wed, Sep 26, 2001 at 03:22:01PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > > > So my suggestion was to look at getting anonymous pages backed by what
> > > > amounts to a shared memory segment.  In that vein.  By using an extent
> > > > based data structure we can get the cost down under the current 8 bits
> > > > per page that we have for the swap counts, and make allocating swap
> > > > pages faster.  And we want to cluster related swap pages anyway so
> > > > an extent based system is a natural fit.
> > >
> > > Much of this goes away if you get rid of both the swap and anonymous page
> > > special cases. Back anonymous pages with the "whoops everything I write here
> > > vanishes mysteriously" file system and swap with a swapfs
> >
> > What exactly is anonymous memory? I thought it is what you do when you
> > want to malloc(), but you want to back that up by swap, not /dev/null.
>
> Anonymous memory is memory which is not backed by a filesystem or a
> device. eg: malloc()ed memory, shmem, mmap(MAP_PRIVATE) on a file (which
> will create anonymous memory as soon as the program which did the mmap
> writes to the mapped memory (COW)), etc.

So... how can alan propose to back anonymous memory with /dev/null?
[see above] It should be backed by swap, no?
								Pavel
-- 
I'm pavel@ucw.cz. "In my country we have almost anarchy and I don't care."
Panos Katsaloulis describing me w.r.t. patents at discuss@linmodems.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
