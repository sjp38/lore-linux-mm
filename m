Subject: Re: broken VM in 2.4.10-pre9
References: <20010925005033.A137@bug.ucw.cz>
	<Pine.LNX.4.21.0109261518520.957-100000@freak.distro.conectiva>
	<20010927014431.C2164@bug.ucw.cz>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 27 Sep 2001 07:52:43 -0600
In-Reply-To: <20010927014431.C2164@bug.ucw.cz>
Message-ID: <m1ite468r8.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pavel Machek <pavel@suse.cz> writes:

> Hi!
>
> > > > > So my suggestion was to look at getting anonymous pages backed by what
> > > > > amounts to a shared memory segment.  In that vein.  By using an extent
> > > > > based data structure we can get the cost down under the current 8 bits
> > > > > per page that we have for the swap counts, and make allocating swap
> > > > > pages faster.  And we want to cluster related swap pages anyway so
> > > > > an extent based system is a natural fit.
> > > >
> > > > Much of this goes away if you get rid of both the swap and anonymous page
> > > > special cases. Back anonymous pages with the "whoops everything I write
> here
>
> > > > vanishes mysteriously" file system and swap with a swapfs
> > >
> > > What exactly is anonymous memory? I thought it is what you do when you
> > > want to malloc(), but you want to back that up by swap, not /dev/null.
> >
> > Anonymous memory is memory which is not backed by a filesystem or a
> > device. eg: malloc()ed memory, shmem, mmap(MAP_PRIVATE) on a file (which
> > will create anonymous memory as soon as the program which did the mmap
> > writes to the mapped memory (COW)), etc.
>
> So... how can alan propose to back anonymous memory with /dev/null?
> [see above] It should be backed by swap, no?

He's not.  Alan if I understand him correctly is advocating remove special
cases.  And making it look like all pages are backed by something.
The /dev/nullfs is just until swap is allocated for that page.

I don't agree with the exact details of what Alan is envsions but I do
argree with the basic idea...

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
