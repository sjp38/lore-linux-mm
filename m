Date: Thu, 29 Aug 2002 14:38:30 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] low-latency zap_page_range()
Message-ID: <20020829213830.GG888@holomorphy.com>
References: <3D6E844C.4E756D10@zip.com.au> <1030653602.939.2677.camel@phantasy> <3D6E8B25.425263D5@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D6E8B25.425263D5@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Robert Love <rml@tech9.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robert Love wrote:
>> unless we
>> wanted to unconditionally drop the locks and let preempt just do the
>> right thing and also reduce SMP lock contention in the SMP case.

On Thu, Aug 29, 2002 at 01:59:17PM -0700, Andrew Morton wrote:
> That's an interesting point.  page_table_lock is one of those locks
> which is occasionally held for ages, and frequently held for a short
> time.
> I suspect that yes, voluntarily popping the lock during the long holdtimes
> will allow other CPUs to get on with stuff, and will provide efficiency
> increases.  (It's a pretty lame way of doing that though).
> But I don't recall seeing nasty page_table_lock spintimes on
> anyone's lockmeter reports, so...

You will. There are just bigger fish to fry at the moment.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
