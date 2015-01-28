Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1DD6B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 09:15:52 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id 142so8985725ykq.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:15:52 -0800 (PST)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id u4si6097774qac.80.2015.01.28.06.15.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 06:15:52 -0800 (PST)
Received: by mail-qg0-f46.google.com with SMTP id i50so16730268qgf.5
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 06:15:51 -0800 (PST)
Message-ID: <54C8EF16.5080701@gmail.com>
Date: Wed, 28 Jan 2015 09:15:50 -0500
From: John Moser <john.r.moser@gmail.com>
MIME-Version: 1.0
Subject: Re: OOM at low page cache?
References: <54C2C89C.8080002@gmail.com> <54C77086.7090505@suse.cz> <20150128062609.GA4706@blaptop>
In-Reply-To: <20150128062609.GA4706@blaptop>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>

On 01/28/2015 01:26 AM, Minchan Kim wrote:
> Hello,
>
> On Tue, Jan 27, 2015 at 12:03:34PM +0100, Vlastimil Babka wrote:
>> CC linux-mm in case somebody has a good answer but missed this in lkml traffic
>>
>> On 01/23/2015 11:18 PM, John Moser wrote:
>>> Why is there no tunable to OOM at low page cache?
> AFAIR, there were several trial although there wasn't acceptable
> at that time. One thing I can remember is min_filelist_kbytes.
> FYI, http://lwn.net/Articles/412313/
>

That looks more straight-forward than http://lwn.net/Articles/422291/


> I'm far away from reclaim code for a long time but when I read again,
> I found something strange.
>
> With having swap in get_scan_count, we keep a mount of file LRU + free
> as above than high wmark to prevent file LRU thrashing but we don't
> with no swap. Why?
>

That's ... strange.  That means having a token 1MB swap file changes the
system's practical memory reclaim behavior dramatically?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
