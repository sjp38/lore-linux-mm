Date: Thu, 23 Aug 2001 10:18:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <m1zo8rl2lt.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33L.0108231017320.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 Aug 2001, Eric W. Biederman wrote:
> Alan Cox <alan@lxorguk.ukuu.org.uk> writes:
>
> > > Suspect code would be:
> > > - tlb optimisations in recent -ac    (tasks dying with segfault)
>
> Can I ask which tlb optimisations these are.

> It is so weird I have been having a hard time believing the bug
> reports.

We found a new suspect last night.  Turns out Linus'
locking overhaul of memory.c results not only in the
kernel dropping locks in critical sections, but also
possibly ends up in the pageout path ...

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
