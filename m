Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BB00D9000C2
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 11:39:51 -0400 (EDT)
Date: Fri, 8 Jul 2011 10:39:48 -0500 (CDT)
From: Chris Pearson <pearson.christopher.j@gmail.com>
Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
In-Reply-To: <CAEwNFnB8VXkTiMzJewtd7rSZ8keqkboNz-BBjw_UudquvsrK1A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1107081021040.29346@ubuntu>
References: <CAGtzr3fm2=UJFRo2xSYhst0P4jCMT-EPjyPi3=icCrMtW0ij8w@mail.gmail.com> <CAEwNFnB8VXkTiMzJewtd7rSZ8keqkboNz-BBjw_UudquvsrK1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

addr1line says vmscan.c:0

I must have not compiled with some debugging info?

On Fri, 8 Jul 2011, Minchan Kim wrote:

>Date: Fri, 8 Jul 2011 14:14:09 +0900
>From: Minchan Kim <minchan.kim@gmail.com>
>To: Chris Pearson <kermit4@gmail.com>
>Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
>Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
>
>On Fri, Jul 8, 2011 at 12:53 AM, Chris Pearson <kermit4@gmail.com> wrote:
>> see attached screenshots
>>
>> NULL pointer dereference at 8
>>
>> isolate_lru_pages
>> shrink_inactive_list
>> __lookup_tag
>> shrink_zone
>> shrink_slab
>> kswapd
>> zone_reclaim
>>
>> These are from 3 different servers in the past week since we upgraded
>> a few hundred of them to 2.6.39.1.    They're under a steady few MB/s
>> of net and disk I/O load.
>>
>> We have the following /proc adjustments:
>>
>> kernel.shmmax = 135217728
>> fs.file-max = 65535
>> vm.swappiness = 10
>> vm.min_free_kbytes = 65535
>>
>
>I didn't have see such BUG until now.
>Could you tell me which point is isolate_lru_pages + 0x225?
>You can get it with addr2line -e vmlinux -i ffffffff8108ed15 or gdb.
>
>The culprit I think is page_count.
>A month ago, Andrea pointed out and sent the patch but it seems it
>isn't stable tree.
>
>Could you test below patch?
>https://patchwork.kernel.org/patch/857442/
>
>
>
>-- 
>Kind regards,
>Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
