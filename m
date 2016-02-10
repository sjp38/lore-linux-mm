Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 40383828DF
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 13:04:57 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id wb13so39391744obb.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 10:04:57 -0800 (PST)
Received: from rcdn-iport-2.cisco.com (rcdn-iport-2.cisco.com. [173.37.86.73])
        by mx.google.com with ESMTPS id wi5si4120717oeb.28.2016.02.10.10.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 10:04:56 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com> <56AAC085.9060509@cisco.com>
 <20160129015534.GA6401@cmpxchg.org> <56ABEAA7.1020706@redhat.com>
 <D2DE3289.2B1F3%khalidm@cisco.com>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56BB7BC7.4040403@cisco.com>
Date: Wed, 10 Feb 2016 10:04:55 -0800
MIME-Version: 1.0
In-Reply-To: <D2DE3289.2B1F3%khalidm@cisco.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Khalid Mughal (khalidm)" <khalidm@cisco.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 02/08/2016 12:57 PM, Khalid Mughal (khalidm) wrote:
> How do we explain the discrepancy between MemAvaiable and MemFree count
> after we drop cache? In following output, which one represents correct
> data?
>
> [Linux_0:/]$ cat /proc/meminfo
> MemTotal:        3977836 kB
> MemFree:          747832 kB
> MemAvailable:    1441736 kB
> Buffers:          123976 kB
> Cached:          1210272 kB
> Active:          2496932 kB
> Inactive:         585364 kB
> Active(anon):    2243932 kB
> Inactive(anon):   142676 kB
> Active(file):     253000 kB
> Inactive(file):   442688 kB
> Dirty:                44 kB
> AnonPages:       1748088 kB
> Mapped:           406512 kB
> Shmem:            638564 kB
> Slab:              65656 kB
> SReclaimable:      30120 kB
> SUnreclaim:        35536 kB
> KernelStack:        5920 kB
> PageTables:        19040 kB
> CommitLimit:     1988916 kB
> Committed_AS:    3765252 kB
>
> [Linux_0:/]$ echo 3 > /proc/sys/vm/drop_caches
> [Linux_0:/]$ cat /proc/meminfo
> MemTotal:        3977836 kB
> MemFree:         1095012 kB
> MemAvailable:    1434148 kB

I suspect MemAvailable takes into account more than just the droppable 
caches. For instance, reclaimable slab is included, but I don't think 
drop_caches drops that part.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
