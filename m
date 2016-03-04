Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id CE6756B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 12:39:19 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p65so976020wmp.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 09:39:19 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 199si96295wmv.97.2016.03.04.09.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 09:39:18 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id p65so116317wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 09:39:18 -0800 (PST)
Date: Fri, 4 Mar 2016 18:39:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160304173916.GA24204@dhcp22.suse.cz>
References: <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
 <20160302140611.GI26686@dhcp22.suse.cz>
 <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
 <20160303092634.GB26202@dhcp22.suse.cz>
 <CAAmzW4NQznWcCWrwKk836yB0bhOaHNygocznzuaj5sJeepHfYQ@mail.gmail.com>
 <20160303152514.GG26202@dhcp22.suse.cz>
 <20160304052327.GA13022@js1304-P5Q-DELUXE>
 <20160304151558.GF31257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160304151558.GF31257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri 04-03-16 16:15:58, Michal Hocko wrote:
> On Fri 04-03-16 14:23:27, Joonsoo Kim wrote:
[...]
> > Unconditional 16 looping and then OOM kill really doesn't make any
> > sense, because it doesn't mean that we already do our best.
> 
> 16 is not really that important. We can change that if that doesn't
> sounds sufficient. But please note that each reclaim round means
> that we have scanned all eligible LRUs to find and reclaim something

this should read "scanned potentially all eligible LRUs..."

> and asked direct compaction to prepare a high order page.
> This sounds like "do our best" to me.


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
