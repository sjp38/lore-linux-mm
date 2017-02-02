Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 884F96B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 17:49:03 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e4so2508617pfg.4
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 14:49:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c82si23563869pfc.179.2017.02.02.14.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 14:49:02 -0800 (PST)
Date: Thu, 2 Feb 2017 14:49:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/7] mm: vmscan: fix kswapd writeback regression v2
Message-Id: <20170202144901.9ae9e2ad6bdd73a75e95f687@linux-foundation.org>
In-Reply-To: <20170202191957.22872-1-hannes@cmpxchg.org>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  2 Feb 2017 14:19:50 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> here are some minor updates to the series. It's nothing functional,
> just code comments and updates to the changelogs from the mailing list
> discussions. Since we don't have a good delta system for changelogs
> I'm resending the entire thing as a drop-in replacement for -mm.

Thanks, I updated the changelogs in place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
