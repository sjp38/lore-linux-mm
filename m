Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
References: <Pine.LNX.4.21.0104121519270.18260-100000@imladris.rielhome.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 13 Apr 2001 00:45:27 -0600
In-Reply-To: Rik van Riel's message of "Thu, 12 Apr 2001 15:25:00 -0300 (BRST)"
Message-ID: <m1wv8pti0o.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:
> 
> 1) you DO need to check to see if the system still has enough
>    free pages
> 2) the cache size may be better expressed as some percentage
>    of system memory ... it's still not good, but the 3 MB you
>    chose is probably completely wrong for 90% of the systems
>    out there ;)
> 
> I believe Andrew Morton was also looking at making changes to the
> out_of_memory() function, but only to make sure the OOM killer
> isn't started to SOON. I guess we can work something out that will
> both kill soon enough *and* not too soon  ;)
> 
> Any suggestions for making Slats' ideas more generic so they work
> on every system ?

Well I don't see how thrashing is necessarily connected to oom
at all.  You could have Gigs of swap not even touched and still
thrash.  

I would suggest adding a user space app to kill ill behaved processes.
It can do all kinds of things like put netscape on it's hit list, have
a config file etc.  But with a mlocked user space app killing ill behaved
processes, we can worry less about a kernel oom.  (Yes the user space
app would need to be static and probably not depend on glibc at all
since it is such a pig, but that shouldn't be a real issue).

The kernel should always wait until it is certain we are out of
memory.  This should give a user space app plenty of time to react.


Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
