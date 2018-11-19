Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECE9D6B1B64
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:48:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id n32-v6so15761650edc.17
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:48:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q23si1017761eds.78.2018.11.19.08.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:48:55 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
References: <20181115131927.GT23831@dhcp22.suse.cz>
 <20181115133840.GR2653@MiWiFi-R3L-srv>
 <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <eb979e1e-e0fc-b1a3-b6cc-70b503a74a20@suse.cz>
 <20181119164618.GQ22247@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c7c20cc5-c2a4-ce61-3d97-56c8acfb13ec@suse.cz>
Date: Mon, 19 Nov 2018 17:46:03 +0100
MIME-Version: 1.0
In-Reply-To: <20181119164618.GQ22247@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 11/19/18 5:46 PM, Michal Hocko wrote:
> On Mon 19-11-18 17:36:21, Vlastimil Babka wrote:
>>
>> So what protects us from locking a page whose refcount dropped to zero?
>> and is being freed? The checks in freeing path won't be happy about a
>> stray lock.
> 
> Nothing really prevents that. But does it matter. The worst that might
> happen is that we lock a freed or reused page. Who would complain?

free_pages_check() for example

PAGE_FLAGS_CHECK_AT_FREE includes PG_locked
