Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id F27B94402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 15:00:07 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so17855818pfn.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 12:00:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i65si14309870pfj.67.2015.12.17.12.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 12:00:06 -0800 (PST)
Date: Thu, 17 Dec 2015 12:00:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-Id: <20151217120004.b5f849e1613a3a367482b379@linux-foundation.org>
In-Reply-To: <CA+55aFxkzeqtxDY8KyR_FA+WKNkQXEHVA_zO8XhW6rqRr778Zw@mail.gmail.com>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
	<20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
	<20151217130223.GE18625@dhcp22.suse.cz>
	<CA+55aFxkzeqtxDY8KyR_FA+WKNkQXEHVA_zO8XhW6rqRr778Zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 17 Dec 2015 11:55:11 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Dec 17, 2015 at 5:02 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > Ups. You are right. I will go with msleep_interruptible(100).
> 
> I don't think that's right.
> 
> If a signal happens, that loop is now (again) just busy-looping.

It's called only by a kernel thread so no signal_pending().  This
relationship is a bit unobvious and fragile, but we do it in quite a
few places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
