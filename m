Date: Thu, 22 Jun 2000 22:19:23 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: [RFC] RSS guarantees and limits
Message-ID: <20000622221923.A8744@redhat.com>
References: <Pine.LNX.4.21.0006211059410.5195-100000@duckman.distro.conectiva> <m2lmzx38a1.fsf@boreas.southchinaseas>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2lmzx38a1.fsf@boreas.southchinaseas>; from vii@penguinpowered.com on Thu, Jun 22, 2000 at 07:00:54PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 22, 2000 at 07:00:54PM +0100, John Fremlin wrote:
> 
> > - protect smaller apps from bigger memory hogs
> 
> Why? Yes, it's very altruistic, very sportsmanlike, but giving small,
> rarely used processes a form of social security is only going to
> increase bureaucracy ;-)

It is critically important that when under memory pressure, a
system administrator can still log in and kill any runaway
processes.  The smaller apps in question here are system daemons
such as init, inetd and telnetd, and user apps such as bash and
ps.  We _must_ be able to allow them to make at least some
progress while the VM is under load.

Cheers, 
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
