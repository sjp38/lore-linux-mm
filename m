Date: Fri, 21 Sep 2001 09:01:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: broken VM in 2.4.10-pre9
In-Reply-To: <m1wv2t7y18.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33L.0109210859390.19147-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 21 Sep 2001, Eric W. Biederman wrote:

> Swapping is an important case.  But 9 times out of 10 you are managing
> memory in caches, and throwing unused pages into swap.  You aren't
> busily paging the data back an forth.  But if I have to make a choice
> in what kind of situation I want to take a performance hit, paging
> approaching thrashing or a system whose working set size is well
> within RAM.  I'd rather take the hit in the system that is paging.

> Besides I also like to run a lot of shell scripts, which again stress
> the fork()/exec()/exit() path.
>
> So no I don't think keeping those paths fast is silly.

Absolutely agreed.

Ben and I have already been thinking a bit about memory
objects, so we have both reverse mappings AND we can skip
copying the page tables at fork() time (needing to clear
less at the subsequent exec(), too) ...

Of course this means I'll throw away my pte-based reverse
mapping code and will look at an object-based reverse mapping
scheme like Ben made for 2.1 and DaveM made for 2.3 ;)

regards,

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
