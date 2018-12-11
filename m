Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECB48E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:35:20 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v64so12812572qka.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:35:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q50si362582qta.261.2018.12.11.02.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 02:35:19 -0800 (PST)
Subject: Re: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
 prematurely
References: <20181211085042.2696-1-osalvador@suse.de>
 <5e3e33e3-bea8-249c-2b05-665f40d70df4@redhat.com>
 <20181211102014.GF1286@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <b0618ef7-8537-f85b-4cba-9a6fb75602f0@redhat.com>
Date: Tue, 11 Dec 2018 11:35:16 +0100
MIME-Version: 1.0
In-Reply-To: <20181211102014.GF1286@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11.12.18 11:20, Michal Hocko wrote:
> On Tue 11-12-18 10:35:53, David Hildenbrand wrote:
>> So somehow remember if we had issues with one page and instead of
>> reporting 0, report e.g. -EAGAIN?
> 
> There is no consumer of the return value right now and it is not really
> clear whether we need one. I would just make do_migrate_range return void.
> 

Well, this would allow optimizations like "No need to check if
everything has been migrated, I can tell you right away that it has been
done".

-- 

Thanks,

David / dhildenb
