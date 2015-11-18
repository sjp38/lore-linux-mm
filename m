Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id BA91B6B0284
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 11:21:33 -0500 (EST)
Received: by iofh3 with SMTP id h3so58867596iof.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:21:33 -0800 (PST)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id h10si5811364igt.85.2015.11.18.08.21.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 08:21:33 -0800 (PST)
Received: by iouu10 with SMTP id u10so59796614iou.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:21:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
Date: Wed, 18 Nov 2015 08:21:32 -0800
Message-ID: <CA+55aFzx6r+_e3qDz2gvHbS=NVMsSd-enVTj2D_vBTr8gvUO4g@mail.gmail.com>
Subject: Re: [RFC 0/3] OOM detection rework v2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Nov 18, 2015 at 5:03 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> The above results do seem optimistic but more loads should be tested
> obviously. I would really appreciate a feedback on the approach I have
> chosen before I go into more tuning. Is this viable way to go?

Tetsuo, does this latest version work for you too?

Andrew - I'm assuming this will all come through you at some point.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
