Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DE2FA6B00C3
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 17:54:56 -0400 (EDT)
Date: Thu, 4 Nov 2010 22:43:56 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
Message-ID: <alpine.LNX.2.00.1011042240340.15856@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>  <AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com>  <20101031173336.GA28141@balbir.in.ibm.com>  <alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
 <alpine.DEB.2.00.1011030937580.10599@router.home>  <AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-@mail.gmail.com> <1288799284.15729.27.camel@Joe-Laptop> <alpine.DEB.2.00.1011031108260.11625@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Joe Perches <joe@perches.com>, jovi zhang <bookjovi@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 2010, Christoph Lameter wrote:

> On Wed, 3 Nov 2010, Joe Perches wrote:
> 
> > On Wed, 2010-11-03 at 23:20 +0800, jovi zhang wrote:
> > > On Wed, Nov 3, 2010 at 10:38 PM, Christoph Lameter <cl@linux.com> wrote:
> > > > On Mon, 1 Nov 2010, Jesper Juhl wrote:
> > > >
> > > >> On Sun, 31 Oct 2010, Balbir Singh wrote:
> > > >
> > > >> > > There are so many placed need vzalloc.
> > > >> > > Thanks, Jesper.
> > > >
> > > >
> > > > Could we avoid this painful exercise with a "semantic patch"?
> >
> > There's an existing cocci kmalloc/memset script.
> 
> I have it in
> /usr/share/doc/coccinelle/examples/janitorings/kzalloc-orig.cocci.gz
> 
> (Ubuntu coccinelle package)
> 
> > Perhaps this is good enough?
> >
> > cp scripts/coccinelle/api/alloc/kzalloc-simple.cocci scripts/coccinelle/api/alloc/vzalloc-simple.cocci
> > sed -i -e 's/kmalloc/vmalloc/g' -e 's/kzalloc/vzalloc/g' scripts/coccinelle/api/alloc/vzalloc-simple.cocci
> 
> Not sure if that is the same script but certainly a good start. Try it and
> see if it catches all the locations that you know of?
> 

I'm aware of coccinelle, but I've never used it and it looks like it'll 
take more than just a few hours to learn, so I'm sticking with 
bash+egrep+manual inspection for now until I get a bit more time on my 
hands to learn coccinelle/spatch.

I assume that not using spatch is not going to be an obstacle to patches 
such as this one getting merged...?


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
