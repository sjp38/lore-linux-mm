Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id A79986B0005
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 14:11:28 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ba1so41369530obb.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:11:28 -0800 (PST)
Received: from alln-iport-7.cisco.com (alln-iport-7.cisco.com. [173.37.142.94])
        by mx.google.com with ESMTPS id v83si795170oig.31.2016.02.10.11.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 11:11:27 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com> <56AAC085.9060509@cisco.com>
 <20160129015534.GA6401@cmpxchg.org> <56ABEAA7.1020706@redhat.com>
 <D2DE3289.2B1F3%khalidm@cisco.com> <56BB7BC7.4040403@cisco.com>
 <56BB7DDE.8080206@intel.com>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56BB8B5E.0@cisco.com>
Date: Wed, 10 Feb 2016 11:11:26 -0800
MIME-Version: 1.0
In-Reply-To: <56BB7DDE.8080206@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 02/10/2016 10:13 AM, Dave Hansen wrote:
> On 02/10/2016 10:04 AM, Daniel Walker wrote:
>>> [Linux_0:/]$ echo 3 > /proc/sys/vm/drop_caches
>>> [Linux_0:/]$ cat /proc/meminfo
>>> MemTotal:        3977836 kB
>>> MemFree:         1095012 kB
>>> MemAvailable:    1434148 kB
>> I suspect MemAvailable takes into account more than just the droppable
>> caches. For instance, reclaimable slab is included, but I don't think
>> drop_caches drops that part.
> There's a bit for page cache and a bit for slab, see:
>
> 	https://kernel.org/doc/Documentation/sysctl/vm.txt
>
>

Ok, then this looks like a defect then. I would think MemAvailable would 
always be smaller then MemFree (after echo 3 > 
/proc/sys/vm/drop_caches).. Unless there is something else be accounted 
for that we aren't aware of.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
