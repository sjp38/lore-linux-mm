Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id EB0E36B0038
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 03:42:37 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id c201so66375889wme.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 00:42:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la9si24318638wjc.64.2015.12.11.00.42.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 11 Dec 2015 00:42:36 -0800 (PST)
Date: Fri, 11 Dec 2015 09:42:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] OOM detection rework v3
Message-ID: <20151211084233.GA32318@dhcp22.suse.cz>
References: <1448974607-10208-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448974607-10208-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi,
are there any fundamental objections to the new approach? I am very well
aware that this is not a small change and it will take some time to
settle but can we move on and get this to mmotm tree (and linux-next) so
that it gets a larger test coverage. I do not think this is a material
for the next merge window. Maybe 4.6?

What do you think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
