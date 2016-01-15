Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 102D96B0268
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 06:16:39 -0500 (EST)
Received: by mail-lf0-f43.google.com with SMTP id m198so133264771lfm.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 03:16:39 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id l17si5451623lfg.245.2016.01.15.03.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 03:16:37 -0800 (PST)
Date: Fri, 15 Jan 2016 14:16:23 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] memcg: Only free spare array when readers are done
Message-ID: <20160115111623.GA13257@esperanza>
References: <001a113abaa499606605294b5b17@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <001a113abaa499606605294b5b17@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martijn Coenen <maco@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 14, 2016 at 02:33:52PM +0100, Martijn Coenen wrote:
> A spare array holding mem cgroup threshold events is kept around
> to make sure we can always safely deregister an event and have an
> array to store the new set of events in.
> 
> In the scenario where we're going from 1 to 0 registered events, the
> pointer to the primary array containing 1 event is copied to the spare
> slot, and then the spare slot is freed because no events are left.
> However, it is freed before calling synchronize_rcu(), which means
> readers may still be accessing threshold->primary after it is freed.
> 
> Fixed by only freeing after synchronize_rcu().
> 
> Signed-off-by: Martijn Coenen <maco@google.com>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
