Date: Fri, 20 Aug 2004 22:21:16 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Lhms-devel] Re: [RFC] free_area[] bitmap elimination [0/3]
Message-ID: <20040821052116.GU11200@holomorphy.com>
References: <4126B3F9.90706@jp.fujitsu.com> <20040821025543.GS11200@holomorphy.com> <20040821.135624.74737461.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040821.135624.74737461.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sat, Aug 21, 2004 at 01:56:24PM +0900, Hirokazu Takahashi wrote:
> I also impressed by your patch.
> In my understanding, the patch assumes that size of mem_map[] in each
> zone must be multiple of 2^MAX_ORDER, right?
> But it doesn't seem it's a big problem, as we can just allocate extra
> mem_map[] to round up if it isn't.

In __free_pages_bulk() changing BUG_ON(bad_range(zone, buddy1)) to
if (bad_range(zone, buddy1)) break; should fix this. The start of
the zone must be aligned to MAX_ORDER so buddy2 doesn't need checks.
It may be worthwhile to make a distinction the bounds checks and the
zone check and to BUG_ON() the zone check in isolation and not repeat
the bounds check for the validity check.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
