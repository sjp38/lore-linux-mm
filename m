Message-ID: <46A9ACB2.9030302@gmail.com>
Date: Fri, 27 Jul 2007 10:28:34 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>	 <46A773EA.5030103@gmail.com>	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>	 <46A81C39.4050009@gmail.com>	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>	 <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>	 <46A98A14.3040300@gmail.com> <1185522844.6295.64.camel@Homer.simpson.net>
In-Reply-To: <1185522844.6295.64.camel@Homer.simpson.net>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andika Triwidada <andika@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/27/2007 09:54 AM, Mike Galbraith wrote:

> On Fri, 2007-07-27 at 08:00 +0200, Rene Herman wrote:
> 
>> The remaining issue of updatedb unnecessarily blowing away VFS caches is 
>> being discussed (*) in a few thread-branches still running.
> 
> If you solve that, the swap thing dies too, they're one and the same
> problem.

I still wonder what the "the swap thing" is though. People just kept saying 
that swap-prefetch helped which would seem to indicate their problem didnt 
have anything to do with updatedb.

Also, I know shit about the VFS so this may well be not very educated but to 
me something like FADV_NOREUSE on a dirfd sounds like a much more promising 
approach than the convoluted userspace schemes being discussed, if only 
because it'll actually be implemented/used.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
