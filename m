Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f44.google.com (mail-vk0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0566B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 00:04:00 -0500 (EST)
Received: by vkha189 with SMTP id a189so47190344vkh.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 21:03:59 -0800 (PST)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id l194si26961371vke.212.2015.11.25.21.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 21:03:59 -0800 (PST)
Received: by vkbs1 with SMTP id s1so47280049vkb.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 21:03:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151126015612.GB13138@js1304-P5Q-DELUXE>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20151125120021.GA27342@dhcp22.suse.cz>
	<20151126015612.GB13138@js1304-P5Q-DELUXE>
Date: Thu, 26 Nov 2015 10:33:59 +0530
Message-ID: <CAOaiJ-=n+fSchrxbB-Lr=bh32HOwsXNLUU==6ZRbbXqufU5n7w@mail.gmail.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
From: vinayak menon <vinayakm.list@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Nov 26, 2015 at 7:26 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Wed, Nov 25, 2015 at 01:00:22PM +0100, Michal Hocko wrote:
>> On Tue 24-11-15 15:22:03, Joonsoo Kim wrote:
>> > When I tested compaction in low memory condition, I found that
>> > my benchmark is stuck in congestion_wait() at shrink_inactive_list().
>> > This stuck last for 1 sec and after then it can escape. More investigation
>> > shows that it is due to stale vmstat value. vmstat is updated every 1 sec
>> > so it is stuck for 1 sec.
>>
>> Wouldn't it be sufficient to use zone_page_state_snapshot in
>> too_many_isolated?
>
This was done by this patch I believe,
http://lkml.iu.edu/hypermail/linux/kernel/1501.2/00001.html, though
the original  issue (wait of more than 1 sec) was fixed by the vmstat
changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
