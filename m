Subject: Re: broken VM in 2.4.10-pre9
References: <Pine.LNX.4.33L.0109192000050.19147-100000@imladris.rielhome.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 21 Sep 2001 02:23:15 -0600
In-Reply-To: <Pine.LNX.4.33L.0109192000050.19147-100000@imladris.rielhome.conectiva>
Message-ID: <m1wv2t7y18.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 19 Sep 2001, Eric W. Biederman wrote:
>
> > That added to the fact that last time someone ran the numbers linux
> > was considerably faster than the BSD for mm type operations when not
> > swapping.  And this is the common case.
>
> Optimising the VM for not swapping sounds kind of like
> optimising your system for doing empty fork()/exec()/exit()
> loops ;)

Swapping is an important case.  But 9 times out of 10 you are managing
memory in caches, and throwing unused pages into swap.  You aren't busily
paging the data back an forth.  But if I have to make a choice in
what kind of situation I want to take a performance hit, paging
approaching thrashing or a system whose working set size is well
within RAM.  I'd rather take the hit in the system that is paging.

Further fast IPC + fork()/exec()/exit() that programmers can count on
leads to more robust programs.  Because different pieces of the program
can live in different processes.  One of the reasons for the stability
of unix is that it has always had a firewall between it's processes so
one bad pointer will not bring down the entire system.

Besides I also like to run a lot of shell scripts, which again stress
the fork()/exec()/exit() path.

So no I don't think keeping those paths fast is silly.

I also think that being able to get good memory usage information is
important.  I know that reverse maps make that job easier.  But just
because the make an important case easier to get write I don't think
reverse maps are a shoe in.

Eric




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
