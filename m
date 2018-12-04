Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 006B96B6F36
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 09:42:12 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b7so8324349eda.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 06:42:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si976468edz.205.2018.12.04.06.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 06:42:10 -0800 (PST)
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
 <20181204072251.GT31738@dhcp22.suse.cz>
 <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ffd7160c-b5dc-364f-a5cd-ac3f16181ced@suse.cz>
Date: Tue, 4 Dec 2018 15:42:08 +0100
MIME-Version: 1.0
In-Reply-To: <20181204085601.GC1286@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On 12/4/18 9:56 AM, Michal Hocko wrote:
>> The device's node num is 2. And in my case, I used nr_cpus param. Due
>> to init_cpu_to_node() initialize all the possible node.  It is hard
>> for me to figure out without this param, how zonelists is accessed
>> before page allocator works.
> I believe we should focus on this. Why does the node have no zonelist
> even though all zonelists should be initialized already? Maybe this is
> nr_cpus pecularity and we do not initialize all the existing numa nodes.
> Or maybe the device is associated to a non-existing node with that
> setup. A full dmesg might help us here.

Yes, a full dmesg should contain line such as this one:

[    0.137407] Built 1 zonelists, mobility grouping on.  Total pages:
6181664

That should at least tell us if nr_cpus=X resulted in some node's
zonelists not being built.
