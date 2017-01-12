Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 486DD6B0069
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:33:16 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id k86so9038844lfi.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:33:16 -0800 (PST)
Received: from smtp33.i.mail.ru (smtp33.i.mail.ru. [94.100.177.93])
        by mx.google.com with ESMTPS id v62si5510236lfa.403.2017.01.12.07.33.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 07:33:14 -0800 (PST)
Date: Thu, 12 Jan 2017 18:33:11 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Message-ID: <20170112153311.GC31816@esperanza>
References: <bug-190841-27@https.bugzilla.kernel.org/>
 <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
 <20170106162827.GA31816@esperanza>
 <CAJABK0M6NYgQRzJnTv0w4qHiyY+zQUHs_5f0_zTNYodDXNi=mQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJABK0M6NYgQRzJnTv0w4qHiyY+zQUHs_5f0_zTNYodDXNi=mQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladyslav Frolov <frolvlad@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Thu, Jan 12, 2017 at 03:55:59PM +0200, Vladyslav Frolov wrote:
> Indeed, `cgroup.memory=nokmem` works around the high load average on
> all the kernels!
> 
> 4.10rc2 kernel without `cgroup.memory=nokmem` behaves much better than
> 4.7-4.9 kernels, yet it still reaches LA ~6 using my reproduction
> script, while LA <=1.0 is expected. 4.10rc2 feels like 4.6, which I
> described as "seminormal".

Thanks for trying it out. I'll think if we can do anything to further
improve performance over the weekend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
