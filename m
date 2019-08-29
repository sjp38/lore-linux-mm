Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D119C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:59:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F26221726
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:59:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F26221726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3CC46B000C; Thu, 29 Aug 2019 12:59:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AED396B000D; Thu, 29 Aug 2019 12:59:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DBDE6B000E; Thu, 29 Aug 2019 12:59:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8516B000C
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:59:36 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3329CABEA
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:59:36 +0000 (UTC)
X-FDA: 75876076752.01.death70_8df9f22afd31d
X-HE-Tag: death70_8df9f22afd31d
X-Filterd-Recvd-Size: 10164
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:59:35 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 80F262A09CD;
	Thu, 29 Aug 2019 16:59:34 +0000 (UTC)
Received: from [10.36.117.243] (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 99BDF600C1;
	Thu, 29 Aug 2019 16:59:32 +0000 (UTC)
Subject: Re: [PATCH v2 3/6] mm/memory_hotplug: Process all zones when removing
 memory
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador
 <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>,
 Wei Yang <richardw.yang@linux.intel.com>
References: <20190826101012.10575-1-david@redhat.com>
 <20190826101012.10575-4-david@redhat.com>
 <20190829153936.GJ28313@dhcp22.suse.cz>
 <c01ceaab-4032-49cd-3888-45838cb46e11@redhat.com>
 <20190829162704.GL28313@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b5a9f070-b43a-c21d-081b-9926b2007f5c@redhat.com>
Date: Thu, 29 Aug 2019 18:59:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190829162704.GL28313@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 29 Aug 2019 16:59:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.08.19 18:27, Michal Hocko wrote:
> On Thu 29-08-19 17:54:35, David Hildenbrand wrote:
>> On 29.08.19 17:39, Michal Hocko wrote:
>>> On Mon 26-08-19 12:10:09, David Hildenbrand wrote:
>>>> It is easier than I though to trigger a kernel bug by removing memory that
>>>> was never onlined. With CONFIG_DEBUG_VM the memmap is initialized with
>>>> garbage, resulting in the detection of a broken zone when removing memory.
>>>> Without CONFIG_DEBUG_VM it is less likely - but we could still have
>>>> garbage in the memmap.
>>>>
>>>> :/# [   23.912993] BUG: unable to handle page fault for address: 000000000000353d
>>>> [   23.914219] #PF: supervisor write access in kernel mode
>>>> [   23.915199] #PF: error_code(0x0002) - not-present page
>>>> [   23.916160] PGD 0 P4D 0
>>>> [   23.916627] Oops: 0002 [#1] SMP PTI
>>>> [   23.917256] CPU: 1 PID: 7 Comm: kworker/u8:0 Not tainted 5.3.0-rc5-next-20190820+ #317
>>>> [   23.918900] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.12.1-0-ga5cab58e9a3f-prebuilt.qemu.4
>>>> [   23.921194] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
>>>> [   23.922249] RIP: 0010:clear_zone_contiguous+0x5/0x10
>>>> [   23.923173] Code: 48 89 c6 48 89 c3 e8 2a fe ff ff 48 85 c0 75 cf 5b 5d c3 c6 85 fd 05 00 00 01 5b 5d c3 0f 1f 840
>>>> [   23.926876] RSP: 0018:ffffad2400043c98 EFLAGS: 00010246
>>>> [   23.927928] RAX: 0000000000000000 RBX: 0000000200000000 RCX: 0000000000000000
>>>> [   23.929458] RDX: 0000000000200000 RSI: 0000000000140000 RDI: 0000000000002f40
>>>> [   23.930899] RBP: 0000000140000000 R08: 0000000000000000 R09: 0000000000000001
>>>> [   23.932362] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000140000
>>>> [   23.933603] R13: 0000000000140000 R14: 0000000000002f40 R15: ffff9e3e7aff3680
>>>> [   23.934913] FS:  0000000000000000(0000) GS:ffff9e3e7bb00000(0000) knlGS:0000000000000000
>>>> [   23.936294] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> [   23.937481] CR2: 000000000000353d CR3: 0000000058610000 CR4: 00000000000006e0
>>>> [   23.938687] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>>> [   23.939889] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>>>> [   23.941168] Call Trace:
>>>> [   23.941580]  __remove_pages+0x4b/0x640
>>>> [   23.942303]  ? mark_held_locks+0x49/0x70
>>>> [   23.943149]  arch_remove_memory+0x63/0x8d
>>>> [   23.943921]  try_remove_memory+0xdb/0x130
>>>> [   23.944766]  ? walk_memory_blocks+0x7f/0x9e
>>>> [   23.945616]  __remove_memory+0xa/0x11
>>>> [   23.946274]  acpi_memory_device_remove+0x70/0x100
>>>> [   23.947308]  acpi_bus_trim+0x55/0x90
>>>> [   23.947914]  acpi_device_hotplug+0x227/0x3a0
>>>> [   23.948714]  acpi_hotplug_work_fn+0x1a/0x30
>>>> [   23.949433]  process_one_work+0x221/0x550
>>>> [   23.950190]  worker_thread+0x50/0x3b0
>>>> [   23.950993]  kthread+0x105/0x140
>>>> [   23.951644]  ? process_one_work+0x550/0x550
>>>> [   23.952508]  ? kthread_park+0x80/0x80
>>>> [   23.953367]  ret_from_fork+0x3a/0x50
>>>> [   23.954025] Modules linked in:
>>>> [   23.954613] CR2: 000000000000353d
>>>> [   23.955248] ---[ end trace 93d982b1fb3e1a69 ]---
>>>
>>> Yes, this is indeed nasty. I didin't think of this when separating
>>> memmap initialization from the hotremove. This means that the zone
>>> pointer is a garbage in arch_remove_memory already. The proper fix is to
>>> remove it from that level down. Moreover the zone is only needed for the
>>> shrinking code and zone continuous thingy. The later belongs to offlining
>>> code unless I am missing something. I can see that you are removing zone
>>> parameter in a later patch but wouldn't it be just better to remove the
>>> whole zone thing in a single patch and have this as a bug fix for a rare
>>> bug with a fixes tag?
>>>
>>
>> If I remember correctly, this patch already fixed the issue for me,
> 
> That might be the case because nothing else does access zone on the way.
> But the pointer is simply bogus. Removing it is the proper way to fix
> it. And I argue that zone shouldn't even be necessary. Re-evaluating
> continuous status of the zone is really something for offlining phase.
> Check how we use pfn_to_online_page there.

Yeah I'm with you, I think you spotted patch 6/6 of this series and v3
already that does exactly that. It's just a matter of rearranging things.

> 
>> without the other cleanup (removing the zone parameter). But I might be
>> wrong.
>>
>> Anyhow, I'll send a v4 shortly (either this evening or tomorrow), so you
>> can safe yourself some review time and wait for that one :)
> 
> No rush, really... It seems this is quite unlikely event as most hotplug
> usecases simply online memory before removing it later on.
> 

I can trigger it reliably right now while working/testing virtio-mem, so
I finally want to clean up this mess :) (has been on my list for a long
time). I'll try to hunt for the right commit id's that broke it.

-- 

Thanks,

David / dhildenb

