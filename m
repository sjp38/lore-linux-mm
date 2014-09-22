Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8016B0037
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 04:25:55 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id eu11so2366303pac.24
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 01:25:55 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o1si10152149pdm.75.2014.09.22.01.25.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 01:25:54 -0700 (PDT)
Date: Mon, 22 Sep 2014 12:25:46 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 2/3] mm: memcontrol: remove obsolete kmemcg pinning tricks
Message-ID: <20140922082546.GB18526@esperanza>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
 <1411243235-24680-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1411243235-24680-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Sep 20, 2014 at 04:00:34PM -0400, Johannes Weiner wrote:
> As charges now pin the css explicitely, there is no more need for
> kmemcg to acquire a proxy reference for outstanding pages during
> offlining, or maintain state to identify such "dead" groups.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
