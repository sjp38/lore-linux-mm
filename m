Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6A96B00C1
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 20:36:32 -0500 (EST)
Message-ID: <4ECC4E1B.9050405@tilera.com>
Date: Tue, 22 Nov 2011 20:36:27 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 0/5] Reduce cross CPU IPI interference
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
In-Reply-To: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On 11/22/2011 6:08 AM, Gilad Ben-Yossef wrote:
> We have lots of infrastructure in place to partition a multi-core system such that we have a group of CPUs that are dedicated to specific task: cgroups, scheduler and interrupt affinity and cpuisol boot parameter. Still, kernel code will some time interrupt all CPUs in the system via IPIs for various needs. These IPIs are useful and cannot be avoided altogether, but in certain cases it is possible to interrupt only specific CPUs that have useful work to
> do and not the entire system.
>
> This patch set, inspired by discussions with Peter Zijlstra and Frederic Weisbecker when testing the nohz task patch set, is a first stab at trying to explore doing this by locating the places where such global IPI calls are being made and turning a global IPI into an IPI for a specific group of CPUs.  The purpose of the patch set is to get feedback if this is the right way to go for dealing with this issue and indeed, if the issue is even worth dealing with at all. Based on the feedback from this patch set I plan to offer further patches that address similar issue in other code paths.
>
> The patch creates an on_each_cpu_mask infrastructure API (derived from existing arch specific versions in Tile and Arm) and uses it to turn two global
> IPI invocation to per CPU group invocations.

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

I think this kind of work is very important as more and more processing
moves to isolated cpus that need protection from miscellaneous kernel
interrupts.  Keep at it! :-)

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
