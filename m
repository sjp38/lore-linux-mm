Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 908DF6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 10:34:06 -0500 (EST)
Received: by yxe10 with SMTP id 10so1031627yxe.12
        for <linux-mm@kvack.org>; Wed, 16 Dec 2009 07:34:04 -0800 (PST)
Date: Wed, 16 Dec 2009 23:35:13 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] mm: introduce dump_page() and print symbolic flag names
Message-ID: <20091216153513.GC2804@hack>
References: <20091216122640.GA13817@localhost> <20091216123310.GA17522@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091216123310.GA17522@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Alex Chiang <achiang@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 16, 2009 at 08:33:10PM +0800, Wu Fengguang wrote:
>On Wed, Dec 16, 2009 at 08:26:40PM +0800, Wu Fengguang wrote:
>> - introduce dump_page() to print the page info for debugging some error condition.
>> - convert three mm users: bad_page(), print_bad_pte() and memory offline failure. 
>> - print an extra field: the symbolic names of page->flags
>> 
>> Example dump_page() output:
>> 
>> [  157.521694] page:ffffea0000a7cba8 count:2 mapcount:1
>> mapping:ffff88001c901791 index:147
>                                 ~~~ this is in fact 0x147
>
>The index value may sometimes be misread as decimal number, shall this
>be fixed by adding a "0x" prefix?


Using '%#x' will do.

Thanks.


>
>> [  157.525570] page flags: 100000000100068(uptodate|lru|active|swapbacked)
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/

-- 
Live like a child, think like the god.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
