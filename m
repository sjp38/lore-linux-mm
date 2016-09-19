Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E7A3C6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 11:43:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so36326099wmg.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 08:43:26 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id g193si9500818lfb.86.2016.09.19.08.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 08:43:24 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id s29so8625562lfg.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 08:43:24 -0700 (PDT)
Date: Mon, 19 Sep 2016 18:43:21 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 2/3] cgroup: duplicate cgroup reference when cloning
 sockets
Message-ID: <20160919154321.GG1989@esperanza>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
 <20160914194846.11153-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914194846.11153-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 14, 2016 at 03:48:45PM -0400, Johannes Weiner wrote:
> From: Johannes Weiner <jweiner@fb.com>
> 
> When a socket is cloned, the associated sock_cgroup_data is duplicated
> but not its reference on the cgroup. As a result, the cgroup reference
> count will underflow when both sockets are destroyed later on.
> 
> Fixes: bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup")
> Cc: <stable@vger.kernel.org> # 4.5+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
