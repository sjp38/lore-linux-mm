Date: Fri, 14 Apr 2000 22:56:24 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: posix_fadvise
Message-ID: <20000414225624.A20940@redhat.com>
References: <m38zyhgn2a.fsf@localhost.localnet> <20000414105811.B29138@pcep-jamie.cern.ch> <m3snwofzo4.fsf@localhost.localnet> <20000414224552.A30555@pcep-jamie.cern.ch> <m3itxkcsfd.fsf@localhost.localnet> <20000414232430.E30555@pcep-jamie.cern.ch> <m3aeiwcqn6.fsf@localhost.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m3aeiwcqn6.fsf@localhost.localnet>; from drepper@redhat.com on Fri, Apr 14, 2000 at 02:35:25PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@cygnus.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, VGER kernel list <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Chuck Lever <cel@monkey.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Apr 14, 2000 at 02:35:25PM -0700, Ulrich Drepper wrote:
> 
> Of course I would prefer if the option in the Linux kernel could do
> what POSIX says and simply add a new option for the current behaviour.
> But nobody listens to me anyway so why bother.

The current behaviour is consistent with a lot of other implementations,
and I've had very specific requests from application vendors that
Linux continue to behave the same way.  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
