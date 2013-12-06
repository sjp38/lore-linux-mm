Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id A33D66B00AC
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 17:51:42 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so1016126yhz.13
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 14:51:42 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id r46si56671920yhm.122.2013.12.06.14.51.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 14:51:41 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id um1so1873450pbc.34
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 14:51:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131204130038.GY11295@suse.de>
References: <CAGVrzcZidrUV93x9t_BwPaDuzgxs-88HoF-HUDRrSEYcfJB_rw@mail.gmail.com>
 <20131204130038.GY11295@suse.de>
From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 6 Dec 2013 14:51:00 -0800
Message-ID: <CAGVrzcYMSVX=xkVqROjouvHpVup+jO00Wb66h2Wd=LFX47rDiw@mail.gmail.com>
Subject: Re: high kswapd CPU usage when executing binaries from NFS w/ CMA and COMPACTION
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, mhocko <mhocko@suse.cz>, hannes <hannes@cmpxchg.org>, riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, "m.szyprowski" <m.szyprowski@samsung.com>, "marc.ceeeee" <marc.ceeeee@gmail.com>

2013/12/4 Mel Gorman <mgorman@suse.de>:
> On Tue, Dec 03, 2013 at 06:30:28PM -0800, Florian Fainelli wrote:
>> Hi all,
>>
>> I am experiencing high kswapd CPU usage on an ARMv7 system running
>> 3.8.13 when executing relatively large binaries from NFS. When this
>> happens kswapd consumes around 55-60% CPU usage and the applications
>> takes a huge time to load.
>>
>
> There were a number of changes made related to how and when kswapd
> stalls, particularly when pages are dirty. Brief check confirms that
>
> git log v3.8..v3.12 --pretty=one --author "Mel Gorman" mm/vmscan.c
>
> NFS dirty pages are problematic for compaction as dirty pages cannot be
> migrated until cleaned. I'd suggest checking if current mainline suffers
> the same problem and if not, focus on patches related to dirty page
> handling and kswapd throttling in mm/vmscan.c as backport candidates.

I have just backported these patches to 3.8.13 and am still seeing the
problem, although kswapd usage dropped considerably (by half
approximately). Will keep you updated once I have properly tested
current mainline on my platform. Thanks!
-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
