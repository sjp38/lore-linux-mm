Date: Fri, 20 Apr 2001 14:14:29 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
In-Reply-To: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
Message-ID: <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: Dave McCracken <dmc@austin.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, James A. Sutherland wrote:

> That's my suspicion too: The "strangled" processes eat up system
> resources and still get nowhere (no win there: might as well suspend
> them until they can run properly!) and you are wasting resources which
> could be put to good use by other processes.

You assumes processes are completely equal or their goodnesses are based
on their thrasing behavior. No. Processes are not like that from user
point of view (admins, app developers) moreover they can have complex
relationships between them.

Kernel must give mechanisms to enforce policies, not to dictate them.
And this can be done even at present. You want to create and solve a
problem that doesn't exist because you don't want to RTFM.

> More to the point, though, what about the worst case, where every
> process is thrashing?

What about the simplest case when one process thrasing? You suspend it
continuously from time to time so it won't finish e.g. in 10 minutes but
in 1 hour.

> With my approach, some processes get suspended, others run to
> completion freeing up resources for others.

This is black magic also. Why do you think they will run to completion
or/and free up memory?

> With this approach, every process will still thrash indefinitely:
> perhaps the effects on other processes will be reduced, but you
> don't actually get out of the hole you're in!

So both approach failed.

	Szaka


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
