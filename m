Date: Mon, 11 Aug 2003 16:39:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test3-mm1
Message-ID: <20030811233943.GI32488@holomorphy.com>
References: <20030811113943.47e5fd85.akpm@osdl.org> <873510000.1060633024@flay> <20030811221628.GR1715@holomorphy.com> <884580000.1060642229@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <884580000.1060642229@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, Aug 11, 2003 at 01:17:04PM -0700, Martin J. Bligh wrote:
>> kpmd_ctor() is unusual; how many runs does this profile represent?
>> Does it represent the first run? Ideally, all your kernel pmd's should
>> be cached. If it's not the first run, then logged slab cache statistics
>> would be interesting to determine whether this is still the case even
>> while effective cacheing is going on or whether slab cache reaping is
>> blowing these things away (i.e. either ineffective cacheing is happening
>> or for some reason cacheing them isn't good enough).

On Mon, Aug 11, 2003 at 03:50:29PM -0700, Martin J. Bligh wrote:
> It's the average of 5 runs, after an initial warmup run which is discarded.


Okay, logging /proc/slabinfo and /proc/meminfo at various points
throughout the run would be helpful here.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
