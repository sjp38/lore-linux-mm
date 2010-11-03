Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DD5D98D0003
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:48:07 -0400 (EDT)
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
From: Joe Perches <joe@perches.com>
In-Reply-To: <AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-@mail.gmail.com>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net>
	 <AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com>
	 <20101031173336.GA28141@balbir.in.ibm.com>
	 <alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
	 <alpine.DEB.2.00.1011030937580.10599@router.home>
	 <AANLkTinhAQ7mNQWtjWCOWEHHwgUf+BynMM7jnVBMG32-@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Nov 2010 08:48:04 -0700
Message-ID: <1288799284.15729.27.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: jovi zhang <bookjovi@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Jesper Juhl <jj@chaosbits.net>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-03 at 23:20 +0800, jovi zhang wrote:
> On Wed, Nov 3, 2010 at 10:38 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Mon, 1 Nov 2010, Jesper Juhl wrote:
> >
> >> On Sun, 31 Oct 2010, Balbir Singh wrote:
> >
> >> > > There are so many placed need vzalloc.
> >> > > Thanks, Jesper.
> >
> >
> > Could we avoid this painful exercise with a "semantic patch"?

There's an existing cocci kmalloc/memset script.

Perhaps this is good enough?

cp scripts/coccinelle/api/alloc/kzalloc-simple.cocci scripts/coccinelle/api/alloc/vzalloc-simple.cocci
sed -i -e 's/kmalloc/vmalloc/g' -e 's/kzalloc/vzalloc/g' scripts/coccinelle/api/alloc/vzalloc-simple.cocci




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
