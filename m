Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.3.95.1020718150735.1373A-100000@chaos.analogic.com>
References: <Pine.LNX.3.95.1020718150735.1373A-100000@chaos.analogic.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 12:22:59 -0700
Message-Id: <1027020179.1085.150.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@chaos.analogic.com
Cc: Szakacsits Szabolcs <szaka@sienet.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 12:19, Richard B. Johnson wrote:

> Okay then. When would it be useful? I read that it would be useful
> in embedded systems, but everything that will ever run on embedded
> systems is known at compile time, or is uploaded by something written
> by an intelligent developer, so I don't think it's useful there. I
> 'do' embedded systems and have never encountered OOM.

I work for an embedded systems company and our customers do have OOM
problems.  The problem is not so much that they _do_ OOM but that they
_can_ - killing a random process is the last thing they want.

Same issue with HA etc... its not preventing OOM so much as being
prepared for it, by pushing the failures into the allocation routines
and out from the page access.

Certainly Alan and RedHat found a need for it, too.  It should be pretty
clear why this is an issue...

> I keep seeing the same thing about protecting root against fork and
> malloc bombs and I get rather "malloc()" about it. All distributions
> I have seen, so far, come with `gcc` and `make`. The kiddies can
> crap all over their kernels at their heart's content. I don't think
> Linux should be reduced to the lowest common denominator.

This is the argument I was making before -- I do not think strict
overcommit should solve this problem (nor can it fully).  This is a
problem to be solved by per-user resource limits.

It is not an issue I care much for either, but this is more than just a
"kiddies" issue.  Unbounded memory growth can happen without evil
intentions and in places e.g. like a university shell server it is
important to protect against.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
