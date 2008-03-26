Date: Wed, 26 Mar 2008 07:19:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] NR_CPUS: increase maximum NR_CPUS to 4096
Message-ID: <20080326061925.GC18301@elte.hu>
References: <20080326014137.934171000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080326014137.934171000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Increases the limit of NR_CPUS to 4096 and introduces a boolean called 
> "MAXSMP" which when set (e.g. "allyesconfig") will set NR_CPUS = 4096 
> and NODES_SHIFT = 9 (512).
> 
> I've been running this config (4k NR_CPUS, 512 Max Nodes) on an AMD 
> box with 2 dual-cores and 4gb memory.  I've also successfully booted 
> it in a simulated 2cpus/1Gb environment.

cool!

this depends on the cpumask changes to work correctly (i.e. to boot at 
all), right?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
