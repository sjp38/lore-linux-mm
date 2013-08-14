Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 329296B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:13:00 -0400 (EDT)
Date: Wed, 14 Aug 2013 14:12:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8] mm: make lru_add_drain_all() selective
Message-Id: <20130814141258.6289d9926944245befffa3af@linux-foundation.org>
In-Reply-To: <201308142029.r7EKTMRw023404@farm-0002.internal.tilera.com>
References: <20130814200748.GI28628@htj.dyndns.org>
	<201308142029.r7EKTMRw023404@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Wed, 14 Aug 2013 16:22:18 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:

> This change makes lru_add_drain_all() only selectively interrupt
> the cpus that have per-cpu free pages that can be drained.
> 
> This is important in nohz mode where calling mlockall(), for
> example, otherwise will interrupt every core unnecessarily.

Changelog isn't very informative.  I added this:

: This is important on workloads where nohz cores are handling 10 Gb traffic
: in userspace.  Those CPUs do not enter the kernel and place pages into LRU
: pagevecs and they really, really don't want to be interrupted, or they
: drop packets on the floor.

to attempt to describe the rationale for the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
