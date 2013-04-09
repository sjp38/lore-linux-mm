Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 5ED6C6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 16:52:51 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 06:48:02 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 805822BB0052
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 06:52:42 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39KdNTg11796778
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 06:39:24 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39KqeoG007905
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 06:52:41 +1000
Message-ID: <51647F94.6000907@linux.vnet.ibm.com>
Date: Tue, 09 Apr 2013 15:52:36 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from
 zram in-memory)
References: <1365400862-9041-1-git-send-email-minchan@kernel.org> <f3c8ef05-a880-47db-86dd-156038fc7d0f@default> <20130409012719.GB3467@blaptop> <20130409013606.GC3467@blaptop>
In-Reply-To: <20130409013606.GC3467@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Shuah Khan <shuah@gonehiking.org>

On 04/08/2013 08:36 PM, Minchan Kim wrote:
> On Tue, Apr 09, 2013 at 10:27:19AM +0900, Minchan Kim wrote:
>> Hi Dan,
>>
>> On Mon, Apr 08, 2013 at 09:32:38AM -0700, Dan Magenheimer wrote:
>>>> From: Minchan Kim [mailto:minchan@kernel.org]
>>>> Sent: Monday, April 08, 2013 12:01 AM
>>>> Subject: [PATCH] mm: remove compressed copy from zram in-memory
>>>
>>> (patch removed)
>>>
>>>> Fragment ratio is almost same but memory consumption and compile time
>>>> is better. I am working to add defragment function of zsmalloc.
>>>
>>> Hi Minchan --
>>>
>>> I would be very interested in your design thoughts on
>>> how you plan to add defragmentation for zsmalloc.  In
>>
>> What I can say now about is only just a word "Compaction".
>> As you know, zsmalloc has a transparent handle so we can do whatever
>> under user. Of course, there is a tradeoff between performance 
>> and memory efficiency. I'm biased to latter for embedded usecase.
>>
>> And I might post it because as you know well, zsmalloc
> 
> Incomplete sentense,
> 
> I might not post it until promoting zsmalloc because as you know well,
> zsmalloc/zram's all new stuffs are blocked into staging tree.
> Even if we could add it into staging, as you know well, staging is where
> every mm guys ignore so we end up needing another round to promote it. sigh.

Yes. The lack of compaction/defragmentation support in zsmalloc has not
been raised as an obstacle to mainline acceptance so I think we should
wait to add new features to a yet-to-be accepted codebase.

Also, I think this feature is more important to zram than it is to
zswap/zcache as they can do writeback to free zpages.  In other words,
the fragmentation is a transient issue for zswap/zcache since writeback
to the swap device is possible.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
