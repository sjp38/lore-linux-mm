Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84DD86B0388
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 01:06:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y187so1947755wmy.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 22:06:51 -0800 (PST)
Received: from vps01.wiesinger.com ([2a02:25b0:aaaa:57a::affe:bade])
        by mx.google.com with ESMTPS id f12si1040441wrf.325.2017.02.27.22.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 22:06:50 -0800 (PST)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <aa4a3217-f94c-0477-b573-796c84255d1e@wiesinger.com>
 <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
 <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
 <20170227082734.GB14029@dhcp22.suse.cz>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <73c9ee73-6981-2597-5692-ad49a41770aa@wiesinger.com>
Date: Tue, 28 Feb 2017 07:06:41 +0100
MIME-Version: 1.0
In-Reply-To: <20170227082734.GB14029@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 27.02.2017 09:27, Michal Hocko wrote:
> On Sun 26-02-17 09:40:42, Gerhard Wiesinger wrote:
>> On 04.01.2017 10:11, Michal Hocko wrote:
>>>> The VM stops working (e.g. not pingable) after around 8h (will be restarted
>>>> automatically), happened serveral times.
>>>>
>>>> Had also further OOMs which I sent to Mincham.
>>> Could you post them to the mailing list as well, please?
>> Still OOMs on dnf update procedure with kernel 4.10: 4.10.0-1.fc26.x86_64 as
>> well on 4.9.9-200.fc25.x86_64
>>
>> On 4.10er kernels:
> [...]
>> kernel: Node 0 DMA32 free:5012kB min:2264kB low:2828kB high:3392kB
>> active_anon:143580kB inactive_anon:143300kB active_file:2576kB
>> inactive_file:2560kB unevictable:0kB writepending:0kB present:376688kB
>> managed:353968kB mlocked:0kB slab_reclaimable:13708kB
>> slab_unreclaimable:18064kB kernel_stack:2352kB pagetables:12888kB bounce:0kB
>> free_pcp:412kB local_pcp:88kB free_cma:0kB
> [...]
>
>> On 4.9er kernels:
> [...]
>> kernel: Node 0 DMA32 free:3356kB min:2668kB low:3332kB high:3996kB
>> active_anon:122148kB inactive_anon:112068kB active_file:81324kB
>> inactive_file:101972kB unevictable:0kB writepending:4648kB present:507760kB
>> managed:484384kB mlocked:0kB slab_reclaimable:17660kB
>> slab_unreclaimable:21404kB kernel_stack:2432kB pagetables:10124kB bounce:0kB
>> free_pcp:120kB local_pcp:0kB free_cma:0kB
> In both cases the amount if free memory is above the min watermark, so
> we shouldn't be hitting the oom. We might have somebody freeing memory
> after the last attempt, though...
>
> [...]
>> Should be very easy to reproduce with a low mem VM (e.g. 192MB) under KVM
>> with ext4 and Fedora 25 and some memory load and updating the VM.
>>
>> Any further progress?
> The linux-next (resp. mmotm tree) has new tracepoints which should help
> to tell us more about what is going on here. Could you try to enable
> oom/reclaim_retry_zone and vmscan/mm_vmscan_direct_reclaim_{begin,end}

Is this available in this version?

https://koji.fedoraproject.org/koji/buildinfo?buildID=862775

kernel-4.11.0-0.rc0.git5.1.fc26

How to enable?


Thnx.

Ciao,

gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
