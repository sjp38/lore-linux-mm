Date: Sun, 30 Apr 2000 04:01:53 +0200 (CEST)
From: Sasi Peter <sape@iq.rulez.org>
Subject: Re: [PATCH] 2.3.99-pre6-7 VM rebalanced
In-Reply-To: <Pine.LNX.4.21.0004261900250.16202-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10004300357400.4270-100000@iq.rulez.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000, Rik van Riel wrote:

> appreciate it if people could take some time and test this patch
> with their workloads on their machines ... every situation is
> different and I'd like to ensure reasonable behaviour on every
> machine.

The problem with this is that even if the kernel is in .99 pre-release
state for several weeks _nothing_ has been changed in it about the RAID
stuff still, so a lot of people using 2.2 + raid 0.90 patch (eg. RedHat
users) _cannot_ change to and try 2.3.99, because their partitions would
not mount.

It seems to me, that if we are talking about widening the testbase for
2.3.99, this is the most important item on Alan's todo list.

--  SaPE

Peter, Sasi <sape@sch.hu>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
