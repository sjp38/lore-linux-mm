Date: Fri, 20 Aug 2004 22:01:58 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC]  free_area[]  bitmap elimination [0/3]
Message-ID: <20040821050158.GT11200@holomorphy.com>
References: <4126B3F9.90706@jp.fujitsu.com> <20040821025543.GS11200@holomorphy.com> <4126D6E5.9070804@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4126D6E5.9070804@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Complexity maybe. But one serious issue this addresses beyond the needs
>> of hotplug memory is that the buddy bitmaps are a heavily random-access
>> data structures not used elsewhere. Consolidating them into the page
>> structures should improve cache locality and motivate this patch beyond
>> just the needs of hotplug memory. Furthermore, the patch also reduces
>> the kernel's overall memory footprint by a small amount.
>> However, I'm concerned about the effectiveness of this specific
>> algorithm for coalescing. A more detailed description may help explain
>> why the effectiveness of coalescing is preserved.

On Sat, Aug 21, 2004 at 02:00:21PM +0900, Hiroyuki KAMEZAWA wrote:
> Thanks for your comment, William-san.
> I'd like to add detailed description on my patch.
> I'm now afraid of the case of memory-hole, I should add 
> page_is_valid(buddy1) before
> accessing buddy1.
> I wrote a draft of description, does this explain what you want to know?

This description is enough for me to understand it fully, thank you much.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
