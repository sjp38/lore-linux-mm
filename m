Date: Mon, 11 Aug 2003 11:05:52 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test3-mm1
Message-ID: <20030811180552.GG32488@holomorphy.com>
References: <20030809203943.3b925a0e.akpm@osdl.org> <94490000.1060612530@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94490000.1060612530@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 11, 2003 at 07:35:31AM -0700, Martin J. Bligh wrote:
> Degredation on kernbench is still there:
> Kernbench: (make -j N vmlinux, where N = 16 x num_cpus)
>                               Elapsed      System        User         CPU
>               2.6.0-test3       45.97      115.83      571.93     1494.50
>           2.6.0-test3-mm1       46.43      122.78      571.87     1496.00
> Quite a bit of extra sys time. I thought the suspected part of the sched
> changes got backed out, but maybe I'm just not following it ...

Is this with or without the unit conversion fix for the load balancer?

It will be load balancing extra-aggressively without the fix.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
