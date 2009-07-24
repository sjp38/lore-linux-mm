Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AC90C6B007E
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 08:05:34 -0400 (EDT)
Date: Fri, 24 Jul 2009 08:05:19 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
Message-ID: <20090724120519.GB16192@think>
References: <20090709110342.2386.A69D9226@jp.fujitsu.com> <20090709130134.GH18008@think> <20090710153349.17EC.A69D9226@jp.fujitsu.com> <7149D747-2769-4559-BAF6-AAD2B6C6C941@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7149D747-2769-4559-BAF6-AAD2B6C6C941@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Felix Blyakher <felixb@sgi.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Eric Sandeen <sandeen@redhat.com>, xfs mailing list <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Olaf Weber <olaf@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 24, 2009 at 12:20:32AM -0500, Felix Blyakher wrote:
>
> On Jul 10, 2009, at 2:12 AM, KOSAKI Motohiro wrote:
>> 3. Current wbc->nr_to_write value is not proper?
>>
>> Current writeback_set_ratelimit() doesn't permit that ratelimit_pages 
>> exceed
>> 4M byte. but it is too low restriction for nowadays.
>> (that's my understand. right?)
>>
>> =======================================================
>> void writeback_set_ratelimit(void)
>> {
>>        ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
>>        if (ratelimit_pages < 16)
>>                ratelimit_pages = 16;
>>        if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
>>                ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
>> }
>> =======================================================
>>
>> Yes, 4M bytes are pretty magical constant. We have three choice
>>  A. Remove magical 4M constant simple (a bit danger)
>
> That's will be outside the xfs, and seems like there is no much interest
> from mm people.
>
>>  B. Decide high border from IO capability

It is worth pointing out that Jens Axboe is planning on more feedback
controlled knobs as part of pdflush rework.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
