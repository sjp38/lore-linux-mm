From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
Date: Mon, 16 Apr 2001 22:06:14 +0100
Message-ID: <ehnmdtcljeb1bttp3r6o6o85b6agda0mdt@4ax.com>
References: <m1wv8pti0o.fsf@frodo.biederman.org> <Pine.LNX.4.21.0104131317110.12164-100000@imladris.rielhome.conectiva> <20010414022048.B10405@redhat.com>
In-Reply-To: <20010414022048.B10405@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Apr 2001 02:20:48 +0100, you wrote:

>Hi,
>
>On Fri, Apr 13, 2001 at 01:20:07PM -0300, Rik van Riel wrote:
>
>> What we'd like to see is have the OOM killer act before the
>> system thrashes ... if only because this thrashing could mean
>> we never actually reach OOM because everything grinds to a
>> halt.
>
>It's almost impossible to tell in advance whether the system is going
>to stabilise on its own when you start getting into a swap storm.
>Going into OOM killer preemptively is going to risk killing tasks
>unnecessarily.  I'd much rather leave the killer as a last-chance
>thing to save us from eternal thrashing, rather than have it try too
>hard to prevent any thrashing in the first place. 
>
>If the workload suddenly changes, for example switching virtual
>desktops on a low memory machine so that suddenly a lot of active
>tasks need swapped out and a great deal of new data becomes
>accessible, you get something that is still a swap storm but which
>will reach equilibrium itself in time, for example.

Ideally, I'd SIGSTOP each thrashing process. That way, enough
processes can be swapped out and KEPT swapped out to allow others to
complete their task, freeing up physical memory. Then you can SIGCONT
the processes you suspended, and make progress that way. There are
risks of "deadlocks", of course - suspend X, and all your graphical
apps will lock up waiting for it. This should lower VM pressure enough
to cause X to be restarted, though...


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
