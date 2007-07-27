Message-ID: <46A9E4FC.80403@gmail.com>
Date: Fri, 27 Jul 2007 14:28:44 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>	 <46A773EA.5030103@gmail.com>	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>	 <46A81C39.4050009@gmail.com>	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>	 <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>	 <46A98A14.3040300@gmail.com> <1185522844.6295.64.camel@Homer.simpson.net>	 <46A9ACB2.9030302@gmail.com> <1185528368.7851.44.camel@Homer.simpson.net>	 <46A9D26E.9010703@gmail.com> <1185536880.8978.34.camel@Homer.simpson.net>
In-Reply-To: <1185536880.8978.34.camel@Homer.simpson.net>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andika Triwidada <andika@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, B.Steinbrink@gmx.de, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On 07/27/2007 01:48 PM, Mike Galbraith wrote:

> physical ram.  If it really does use only free ram, that indeed sounds
> pretty pointless.

Con's quote from a bit below that seems to confirm the "only free" nicely.

> I believe the users who say their apps really do get paged back in
> though, so suspect that's not the case.

Stopping the bush-circumference beating, I do not. -ck (and gentoo) have 
this massive Calimero thing going among their users where people are much 
less interested in technology than in how the nasty big kernel meanies are 
keeping them down (*).

Nick Piggin has been unable to get anyone to substantiate anything it seems 
and even this thread alone (and I privately) received a few "oh, heh, sorry, 
I don't actually have a friggin' clue what I'm talking about" responses. As 
such, I believe it's fairly safe to dump the updatedb thing in the garbage 
as not a practical problem.

Leaves the issue of for example a midnight backup run that could very well 
itself grow large enough to leave massive amounts of free memory at exit 
which swap-prefetch _would_ help with. I haven't much opinion on how 
important such situations are but trying to do something to help those seems 
sensible in itself.

Rene.

(*) which isn't to say that you guys aren't in fact nasty big kernel meanies 
ofcourse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
