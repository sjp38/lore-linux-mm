Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6598E6B003A
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:03:26 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hi5so2542177wib.2
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 09:03:25 -0800 (PST)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id m18si7924802wie.85.2014.01.13.09.03.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 09:03:25 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id hq4so2533547wib.3
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 09:03:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140103151154.GA2940@cerebellum.variantweb.net>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org> <20140103151154.GA2940@cerebellum.variantweb.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 13 Jan 2014 12:03:05 -0500
Message-ID: <CALZtONB30aBBY=jPJmXJN9gfSwv8Q4i5=VPpa457TtvSEg4yXQ@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: add writethrough option
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

Ping to see if this patch can get picked up.

On Fri, Jan 3, 2014 at 10:11 AM, Seth Jennings <sjennings@variantweb.net> wrote:
> On Thu, Dec 19, 2013 at 08:23:27AM -0500, Dan Streetman wrote:
>> Currently, zswap is writeback cache; stored pages are not sent
>> to swap disk, and when zswap wants to evict old pages it must
>> first write them back to swap cache/disk manually.  This avoids
>> swap out disk I/O up front, but only moves that disk I/O to
>> the writeback case (for pages that are evicted), and adds the
>> overhead of having to uncompress the evicted pages and the
>> need for an additional free page (to store the uncompressed page).
>>
>> This optionally changes zswap to writethrough cache by enabling
>> frontswap_writethrough() before registering, so that any
>> successful page store will also be written to swap disk.  The
>> default remains writeback.  To enable writethrough, the param
>> zswap.writethrough=1 must be used at boot.
>>
>> Whether writeback or writethrough will provide better performance
>> depends on many factors including disk I/O speed/throughput,
>> CPU speed(s), system load, etc.  In most cases it is likely
>> that writeback has better performance than writethrough before
>> zswap is full, but after zswap fills up writethrough has
>> better performance than writeback.
>>
>> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
>
> Hey Dan, sorry for the delay on this.  Vacation and busyness.
>
> This looks like a good option for those that don't mind having
> the write overhead to ensure that things don't really bog down
> if the compress pool overflows, while maintaining the read fault
> speedup by decompressing from the pool.
>
> Acked-by: Seth Jennings <sjennings@variantweb.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
