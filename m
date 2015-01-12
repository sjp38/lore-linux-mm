Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7239D6B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:59:38 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id 20so10632539yks.9
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:59:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 84si9959466ykz.71.2015.01.12.15.59.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:59:37 -0800 (PST)
Date: Mon, 12 Jan 2015 15:59:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v3 0/5] OOM vs PM freezer fixes
Message-Id: <20150112155935.21b13bc41417ceedde9d640f@linux-foundation.org>
In-Reply-To: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
References: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Fri,  9 Jan 2015 12:05:50 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> Hi,

I've been cheerily ignoring this discussion, sorry.  I trust everyone's
all happy and ready to go with this?

> [what changed since the last patchset]
>
> ...
>
> [testing results]
>
> ...
>
> [overview of the 5 patches]
>
> ...
> 

That's nice, but it doesn't really tell us what the patchset does.  The
first paragraph of the [5/5] changelog provides hints, but doesn't
explain why we even need to fix a race which is "quite small and really
unlikely".

So...  could we please have a few words describing the overall intent
and effect of this patchset?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
