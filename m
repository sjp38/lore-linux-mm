Date: Wed, 26 Apr 2000 12:06:38 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pressuring dirty pages (2.3.99-pre6)
Message-ID: <20000426120638.F3792@redhat.com>
References: <852568CC.004F0BB1.00@raylex-gh01.eo.ray.com> <20000425173012.B1406@redhat.com> <m1snwadmcp.fsf@flinx.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1snwadmcp.fsf@flinx.biederman.org>; from ebiederman@uswest.net on Tue, Apr 25, 2000 at 02:14:30PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederman@uswest.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org, riel@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 25, 2000 at 02:14:30PM -0500, Eric W. Biederman wrote:

> Right.  A RSS guarantee sounds like it would make for easier tuning.
> But a hard RSS max has the advantage of hitting a memory space hog
> early, before it has a chance to get all of memory dirty, and simply
> penalizes the hog.  

Agreed --- RSS limits for the biggest processes in the system are
definitely needed.
 
> Also under heave load a RSS garantee and a RSS hard limit are the
> same.

Not at all --- that's only the case if you only have one process 
experiencing memory pressure, or if you are in equilibrium.  It's the
bits in between, where we are under changing load, which are the most
interesting, and in that case you still want your smallest processes to
have the protection of the RSS guarantees while you start dynamically
reducing the RSS limit on the biggest processes.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
