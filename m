Date: Fri, 6 Oct 2000 13:14:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VM
In-Reply-To: <qwwlmwgjjng.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0010061310290.13585-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[replying to a really old email now that I've started work
 on integrating the OOM handler]

On 25 Sep 2000, Christoph Rohland wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> 
> > > Because as you said the machine can lockup when you run out of memory.
> > 
> > The fix for this is to kill a user process when you're OOM
> > (you need to do this anyway).
> > 
> > The last few allocations of the "condemned" process can come
> > frome the reserved pages and the process we killed will exit just
> > fine.
> 
> It's slightly offtopic, but you should think about detached shm
> segments in yout OOM killer. As many of the high end
> applications like databases and e.g. SAP have most of the memory
> in shm segments you easily end up killing a lot of processes
> without freeing a lot of memory. I see this often in my shm
> tests.

Hmmm, could you help me with drawing up a selection algorithm
on how to choose which SHM segment to destroy when we run OOM?

The criteria would be about the same as with normal programs:

1) minimise the amount of work lost
2) try to protect 'innocent' stuff
3) try to kill only one thing
4) don't surprise the user, but chose something that
   the user will expect to be killed/destroyed

regards,

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
