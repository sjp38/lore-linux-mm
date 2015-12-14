Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C10616B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 05:13:23 -0500 (EST)
Received: by wmnn186 with SMTP id n186so113579720wmn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 02:13:23 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id x9si44867692wjf.139.2015.12.14.02.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 02:13:22 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id p66so54358697wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 02:13:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151214100556.GB4540@dhcp22.suse.cz>
References: <20151210154801.GA12007@lahna.fi.intel.com>
	<20151214092433.GA90449@black.fi.intel.com>
	<20151214100556.GB4540@dhcp22.suse.cz>
Date: Mon, 14 Dec 2015 13:13:22 +0300
Message-ID: <CAPAsAGzrOQAABhOta_o-MzocnikjPtwJLfEKQJ3n5mbBm0T7Bw@mail.gmail.com>
Subject: Re: mm related crash
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mika Westerberg <mika.westerberg@intel.com>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2015-12-14 13:05 GMT+03:00 Michal Hocko <mhocko@suse.cz>:
> On Mon 14-12-15 11:24:33, Kirill A. Shutemov wrote:
>> On Thu, Dec 10, 2015 at 05:48:01PM +0200, Mika Westerberg wrote:
>> > Hi Kirill,
>> >
>> > I got following crash on my desktop machine while building swift. It
>> > reproduces pretty easily on 4.4-rc4.
>> >
>> > Before it happens the ld process is killed by OOM killer. I attached the
>> > whole dmesg.
>> >
>> > [  254.740603] page:ffffea00111c31c0 count:2 mapcount:0 mapping:          (null) index:0x0
>> > [  254.740636] flags: 0x5fff8000048028(uptodate|lru|swapcache|swapbacked)
>> > [  254.740655] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
>> > [  254.740679] ------------[ cut here ]------------
>> > [  254.740690] kernel BUG at mm/memcontrol.c:5270!
>>
>>
>> Hm. I don't see how this can happen.
>
> What a coincidence. I have just posted a similar report:
> http://lkml.kernel.org/r/20151214100156.GA4540@dhcp22.suse.cz except I
> have hit the VM_BUG_ON from a different path. My suspicion is that
> somebody unlocks the page while we are waiting on the writeback.
> I am trying to reproduce this now.

Guys, this is fixed in rc5 - dfd01f026058a ("sched/wait: Fix the
signal handling fix").
http://lkml.kernel.org/r/<20151212162342.GF11257@ret.masoncoding.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
