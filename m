Message-ID: <480E9C2B.4060508@cn.fujitsu.com>
Date: Wed, 23 Apr 2008 10:17:15 +0800
From: Shi Weihua <shiwh@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] Fix usemap initialization v2
References: <20080418161522.GB9147@csn.ul.ie> <48080706.50305@cn.fujitsu.com> <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com> <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com> <21878461.1208539556838.kamezawa.hiroyu@jp.fujitsu.com> <20080421112048.78f0ec76.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0804211250000.16476@blonde.site> <20080422104043.215c7dc4.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0804221106250.12316@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0804221106250.12316@blonde.site>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote::
> On Tue, 22 Apr 2008, KAMEZAWA Hiroyuki wrote:
>> Tested on ia64/2.6.25
>>    DISCONTIGMEM + 16KB/64KB pages
>>    SPARSEMEM    + 16KB/64KB pages
>> seems no troubles.
>>
>> Thanks,
>> -Kame
> 
> Looks good to me, if Mel and Shi approve.  (Well, there are two typos,
> "creted" should be "created" and "migratetpye" should be "migratetype".)

I will confirm Kamezawa-san's patch as soon as possible. Maybe this afternoon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
