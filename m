Date: Sat, 24 Mar 2001 02:08:17 +0000 (GMT)
From: Paul Jakma <paul@jakma.org>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <Pine.LNX.4.30.0103232312440.13864-100000@fs131-224.f-secure.com>
Message-ID: <Pine.LNX.4.33.0103240203340.11627-100000@fogarty.jakma.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Paul Jakma <paulj@itg.ie>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 24 Mar 2001, Szabolcs Szakacsits wrote:

> Nonsense hodgepodge. See and/or mesaure the impact. I sent numbers in my
> former email. You also missed non-overcommit must be _optional_ [i.e.
> you wouldn't be forced to use it ;)]. Yes, there are users and
> enterprises who require it and would happily pay the 50-100% extra swap
> space for the same workload and extra reliability.

ok.. the last time OOM came up, the main objection to fully
guaranteed vm was the possible huge overhead.

if someone knows how to do it without a huge overhead, i'd love to
see it and try it out.

> At every time you add/delete users, add/delete special apps, etc.

no.. pam_limits knows about groups, and you can specify limit for
that group, one time.

@user ... ... ...

> Rik's killer is quite fine at _default_. But there will be always
> people who won't like it

exactly... so lets try avoid ever needing it. it is a last resort.

> default, use the /proc/sys/vm/oom_killer interface"? As I said
> before there are also such patch by Chris Swiedler and definitely
> not a huge, complex one.

uhmm.. where?

> And these stupid threads could be forgotten for good and all.

:)

> 	Szaka

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org
PGP5 key: http://www.clubi.ie/jakma/publickey.txt
-------------------------------------------
Fortune:
The optimum committee has no members.
		-- Norman Augustine

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
