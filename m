Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51B1D6B0033
	for <linux-mm@kvack.org>; Tue, 26 Dec 2017 15:40:34 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id p197so18208980vkf.14
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 12:40:34 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w2sor7062163uad.96.2017.12.26.12.40.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Dec 2017 12:40:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170112153311.GC31816@esperanza>
References: <bug-190841-27@https.bugzilla.kernel.org/> <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
 <20170106162827.GA31816@esperanza> <CAJABK0M6NYgQRzJnTv0w4qHiyY+zQUHs_5f0_zTNYodDXNi=mQ@mail.gmail.com>
 <20170112153311.GC31816@esperanza>
From: Vladyslav Frolov <frolvlad@gmail.com>
Date: Tue, 26 Dec 2017 22:40:12 +0200
Message-ID: <CAJABK0OPyTO4zgmoZ3-=XFT_C0b_MTWVKiVLvsx8QsnLZZ=u7Q@mail.gmail.com>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

It seems that this issue has been fixed in one of the recent major
releases. I cannot reproduce it on 4.14.8 now (I still can reproduce
the issue on the same host with the older kernels and even with 4.9.71
LTS).

Can someone close the issue on bugzilla?

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
