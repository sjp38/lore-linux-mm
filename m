Message-ID: <20000624192245.A6617@saw.sw.com.sg>
Date: Sat, 24 Jun 2000 19:22:45 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: RSS guarantees and limits
References: <Pine.LNX.4.21.0006211059410.5195-100000@duckman.distro.conectiva> <m2lmzx38a1.fsf@boreas.southchinaseas> <20000622221923.A8744@redhat.com> <m2og4t9w7j.fsf@boreas.southchinaseas>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2og4t9w7j.fsf@boreas.southchinaseas>; from "John Fremlin" on Thu, Jun 22, 2000 at 11:39:44PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hello John,

On Thu, Jun 22, 2000 at 11:39:44PM +0100, John Fremlin wrote:
> Stephen Tweedie <sct@redhat.com> writes:
> > It is critically important that when under memory pressure, a
> > system administrator can still log in and kill any runaway
> > processes.  The smaller apps in question here are system daemons
> > such as init, inetd and telnetd, and user apps such as bash and
> > ps.  We _must_ be able to allow them to make at least some
> > progress while the VM is under load.
> 
> I agree completely. It was one of the reasons I suggested that a
> syscall like nice but giving info to the mm layer would be useful. In
> general, small apps (xeyes,biff,gpm) don't deserve any special
> treatment.
> 
> I also said that on a multiuser system it is important that one user
> can't hog the system. In the case where it is impossible for a large
> app to drop root privileges being root wouldn't help unless an
> exception were made for admin caps.

That is exactly my reasons of addressing memory management in the user
beancounter patch:
 - users (and administrator) should have a protection against misbehavior of
   other user's processes;
 - we really care about certain processes which we need for system management
   under memory pressure, rather than about small applications.
Small applications are not always good, as well as big are not bad.
We just want good memory service for those applications which we want to have
it :-)  It hears like tautology, but that it.  It's completely administrator
policy decision.

> The only general solution I can see is to give some process (groups) a
> higher MM priority, by analogy with nice.

Considering the problem, I stated it in a form of guarantee rather than
priority.  Let's consider nice analogy: you can ruin the latency of a
high-priority process by spawning a huge amount lower-priority ones.
Guarantee-like approach gives you configured amount of resources
independently of behavior (or misbehavior) of other processes and users.

> It is critically important that an admin can login to kill a swarm of
> tiny runaway processes. A tiny program that forks every few seconds
> can bring down a machine just as, if not more effectively than, a
> couple of large runaways.

Best regards
					Andrey V.
					Savochkin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
