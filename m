Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 356CB6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 11:31:56 -0400 (EDT)
Received: by lbbud7 with SMTP id ud7so5507098lbb.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:31:55 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id wk8si21766487lbb.96.2015.07.29.08.31.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 08:31:54 -0700 (PDT)
Date: Wed, 29 Jul 2015 18:31:35 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150729153135.GW8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
 <CANN689HJX2ZL891uOd8TW9ct4PNH9d5odQZm86WMxkpkCWhA-w@mail.gmail.com>
 <20150729144539.GU8100@esperanza>
 <CANN689Euq3Y-CHQo8q88vzFAYZX4S6rK+rZRfbuSKfS74u=gcg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CANN689Euq3Y-CHQo8q88vzFAYZX4S6rK+rZRfbuSKfS74u=gcg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 29, 2015 at 08:08:22AM -0700, Michel Lespinasse wrote:
> On Wed, Jul 29, 2015 at 7:45 AM, Vladimir Davydov <vdavydov@parallels.com>
> wrote:
> > Page table scan approach has the inherent problem - it ignores unmapped
> > page cache. If a workload does a lot of read/write or map-access-unmap
> > operations, we won't be able to even roughly estimate its wss.
> 
> You can catch that in mark_page_accessed on those paths, though.

Actually, the problem here is how to find an unmapped page cache page
*to mark it idle*, not to mark it accessed.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
