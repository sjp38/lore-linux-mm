Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1AEA26B0078
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 13:19:52 -0500 (EST)
Date: Mon, 18 Jan 2010 20:19:42 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100118181942.GD22111@redhat.com>
References: <20100118133755.GG30698@redhat.com>
 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
 <20100118141938.GI30698@redhat.com>
 <84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
 <20100118170816.GA22111@redhat.com>
 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 08:09:26PM +0200, Pekka Enberg wrote:
> Hi Gleb,
> 
> On Mon, Jan 18, 2010 at 7:08 PM, Gleb Natapov <gleb@redhat.com> wrote:
> >> "Greater control" is not an argument for adding a new API that needs
> >> to be maintained forever, a real world use case is.
> >>
> > If there is real world use case for mlockall() there is real use case for
> > this too. People seems to be trying to convince me that I don't need
> > mlockall() without proposing alternatives. The only alternative I see
> > lock everything from userspace.
> >
> >> And yes, this stuff needs to be in the changelog. Whether you want to
> >> spell it out or post an URL to some previous discussion is up to you.
> > The discussion was here just a couple of days ago. Here is the link
> > were I describe my use case: http://marc.info/?l=linux-mm&m=126345374125942&w=2
> > If you think it needs to be spelled out in commit log I'll do it.
> 
> So this is a performance thing? Btw, is there are reason you can't use
> plain mlock() for it as suggested by Peter earlier?
> 
I can't realistically chase every address space mapping changes and mlock
new areas. The only way other then mlockall() is to use custom memory
allocator that allocates mlocked memory.
 
--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
