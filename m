Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id mAB8RcjB026840
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 00:27:38 -0800
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by spaceape14.eur.corp.google.com with ESMTP id mAB8R8Gx031590
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 00:27:36 -0800
Received: by rv-out-0506.google.com with SMTP id b25so2858581rvf.45
        for <linux-mm@kvack.org>; Tue, 11 Nov 2008 00:27:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <604427e00811102042x202906ecq2a10eb5e404e2ec9@mail.gmail.com>
References: <604427e00811031340k56634773g6e260d79e6cb51e7@mail.gmail.com>
	 <604427e00811031419k2e990061kdb03f4b715b51fb9@mail.gmail.com>
	 <20081106143438.5557b87c.kamezawa.hiroyu@jp.fujitsu.com>
	 <604427e00811102042x202906ecq2a10eb5e404e2ec9@mail.gmail.com>
Date: Tue, 11 Nov 2008 00:27:36 -0800
Message-ID: <6599ad830811110027r3f7232fai26164d65b2859143@mail.gmail.com>
Subject: Re: [RFC][PATCH]Per-cgroup OOM handler
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Rohit Seth <rohitseth@google.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 10, 2008 at 8:42 PM, Ying Han <yinghan@google.com> wrote:
>> OOM-handler shoule be in another cpuset or mlocked in this case
>
> The oom-handler is in the same cgroup as the ooming task.

No, that's not how we've been using it - the OOM handler runs in a
system-control cpuset that hopefully doesn't end up OOMing itself.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
