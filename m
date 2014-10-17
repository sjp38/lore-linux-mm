Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 82C866B0069
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 04:49:01 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so421251pde.28
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 01:49:01 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id se5si674100pbc.27.2014.10.17.01.49.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Oct 2014 01:49:00 -0700 (PDT)
Date: Fri, 17 Oct 2014 10:48:41 +0200
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 5/5] mm: memcontrol: remove synchroneous stock draining
 code
Message-ID: <20141017084841.GD5641@esperanza>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
 <1413303637-23862-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1413303637-23862-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 14, 2014 at 12:20:37PM -0400, Johannes Weiner wrote:
> With charge reparenting, the last synchroneous stock drainer left.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
