Subject: Re: [RFC] RSS guarantees and limits
References: <Pine.LNX.4.21.0006211059410.5195-100000@duckman.distro.conectiva> <m2lmzx38a1.fsf@boreas.southchinaseas> <20000622221923.A8744@redhat.com>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 22 Jun 2000 23:39:44 +0100
In-Reply-To: Stephen Tweedie's message of "Thu, 22 Jun 2000 22:19:23 +0100"
Message-ID: <m2og4t9w7j.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Tweedie <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen Tweedie <sct@redhat.com> writes:

> On Thu, Jun 22, 2000 at 07:00:54PM +0100, John Fremlin wrote:
> > 
> > > - protect smaller apps from bigger memory hogs
> > 
> > Why? Yes, it's very altruistic, very sportsmanlike, but giving small,
> > rarely used processes a form of social security is only going to
> > increase bureaucracy ;-)
> 
> It is critically important that when under memory pressure, a
> system administrator can still log in and kill any runaway
> processes.  The smaller apps in question here are system daemons
> such as init, inetd and telnetd, and user apps such as bash and
> ps.  We _must_ be able to allow them to make at least some
> progress while the VM is under load.

I agree completely. It was one of the reasons I suggested that a
syscall like nice but giving info to the mm layer would be useful. In
general, small apps (xeyes,biff,gpm) don't deserve any special
treatment.

I also said that on a multiuser system it is important that one user
can't hog the system. In the case where it is impossible for a large
app to drop root privileges being root wouldn't help unless an
exception were made for admin caps.

The only general solution I can see is to give some process (groups) a
higher MM priority, by analogy with nice.

It is critically important that an admin can login to kill a swarm of
tiny runaway processes. A tiny program that forks every few seconds
can bring down a machine just as, if not more effectively than, a
couple of large runaways.

[...]

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
