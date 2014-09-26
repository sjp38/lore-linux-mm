Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CB1636B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:25:37 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so2341594pab.34
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 04:25:37 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gi6si8797565pbd.102.2014.09.26.04.25.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 04:25:36 -0700 (PDT)
Date: Fri, 26 Sep 2014 15:25:24 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 2/3] mm: hugetlb_controller: convert to lockless page
 counters
Message-ID: <20140926112524.GF29445@esperanza>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1411573390-9601-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 24, 2014 at 11:43:09AM -0400, Johannes Weiner wrote:
> Abandon the spinlock-protected byte counters in favor of the unlocked
> page counters in the hugetlb controller as well.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
