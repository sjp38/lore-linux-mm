Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B61D76B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 12:01:34 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s141-v6so2016919pgs.23
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 09:01:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 133-v6si870305pfb.41.2018.11.02.09.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 09:01:33 -0700 (PDT)
Date: Fri, 2 Nov 2018 12:01:22 -0400
From: Sasha Levin <sashal@kernel.org>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20181102160122.GH194472@sasha-vm>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>
Cc: Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 02:45:42AM +0000, Dexuan Cui wrote:
>> From: Roman Gushchin <guro@fb.com>
>> Sent: Thursday, November 1, 2018 17:58
>>
>> On Fri, Nov 02, 2018 at 12:16:02AM +0000, Dexuan Cui wrote:
>> Hello, Dexuan!
>>
>> A couple of issues has been revealed recently, here are fixes
>> (hashes are from the next tree):
>>
>> 5f4b04528b5f mm: don't reclaim inodes with many attached pages
>> 5a03b371ad6a mm: handle no memcg case in memcg_kmem_charge()
>> properly
>>
>> These two patches should be added to the serie.
>
>Thanks for the new info!
>
>> Re stable backporting, I'd really wait for some time. Memory reclaim is a
>> quite complex and fragile area, so even if patches are correct by themselves,
>> they can easily cause a regression by revealing some other issues (as it was
>> with the inode reclaim case).
>
>I totally agree. I'm now just wondering if there is any temporary workaround,
>even if that means we have to run the kernel with some features disabled or
>with a suboptimal performance?

I'm not sure what workload you're seeing it on, but if you could merge
these 7 patches and see that it solves the problem you're seeing and
doesn't cause any regressions it'll be a useful test for the rest of us.

--
Thanks,
Sasha
