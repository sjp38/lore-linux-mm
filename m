Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFAC36B0272
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 04:39:09 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id h68so36813564qke.3
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 01:39:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m29si665488qtm.216.2018.11.14.01.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 01:39:09 -0800 (PST)
Subject: Re: Memory hotplug softlock issue
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
 <5a6c6d6b-ebcd-8bfa-d6e0-4312bfe86586@redhat.com>
 <20181114090134.GG23419@dhcp22.suse.cz>
 <4449a0a2-be72-02bb-9f02-ed2484b160f8@redhat.com>
 <20181114093720.GI23419@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <88b7d3a8-3d51-4516-aaee-ba7397796c36@redhat.com>
Date: Wed, 14 Nov 2018 10:39:06 +0100
MIME-Version: 1.0
In-Reply-To: <20181114093720.GI23419@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

>>> Failing on ENOMEM is a questionable thing. I haven't seen that happening
>>> wildly but if it is a case then I wouldn't be opposed.
>>>
>>>> You mentioned memory pressure, if our host is under memory pressure we
>>>> can easily trigger running into an endless loop there, because we
>>>> basically ignore -ENOMEM e.g. when we cannot get a page to migrate some
>>>> memory to be offlined. I assume this is the case here.
>>>> do_migrate_range() could be the bad boy if it keeps failing forever and
>>>> we keep retrying.
>>
>> I've seen quite some issues while playing with virtio-mem, but didn't
>> have the time to look into the details. Still on my long list of things
>> to look into.
> 
> Memory hotplug is really far away from being optimal and robust. This
> has always been the case. Issues used to be workaround by retry limits
> etc. If we ever want to make it more robust we have to bite a bullet and
> actually chase all the issues that might be basically anywhere and fix
> them. This is just a nature of a pony that memory hotplug is.
> 

Yes I agree, no more workarounds.

-- 

Thanks,

David / dhildenb
