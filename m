Date: Fri, 20 Aug 2004 22:37:35 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Lhms-devel] Re: [RFC] free_area[] bitmap elimination [0/3]
Message-ID: <20040821053735.GV11200@holomorphy.com>
References: <4126B3F9.90706@jp.fujitsu.com> <20040821025543.GS11200@holomorphy.com> <20040821.135624.74737461.taka@valinux.co.jp> <20040821052116.GU11200@holomorphy.com> <4126DFB4.7070404@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4126DFB4.7070404@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> In __free_pages_bulk() changing BUG_ON(bad_range(zone, buddy1)) to
>> if (bad_range(zone, buddy1)) break; should fix this. The start of
>> the zone must be aligned to MAX_ORDER so buddy2 doesn't need checks.
>> It may be worthwhile to make a distinction the bounds checks and the
>> zone check and to BUG_ON() the zone check in isolation and not repeat
>> the bounds check for the validity check.

On Sat, Aug 21, 2004 at 02:37:56PM +0900, Hiroyuki KAMEZAWA wrote:
> Okay, I understand several BUG_ON() are needless.
> I'll be more carefull to recognize what is checked.

It's not that it's needless, it's that beforehand the bitmap rounding
up to an even number ensured the __test_and_change_bit() check would
prevent the bounds check from ever failing, but after the bitmap is
eliminated, the bounds check is needed to see if we're even examining
a valid page structure for whether the page can be merged.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
