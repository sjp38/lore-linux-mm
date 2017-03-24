Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED30F6B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:09:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l43so9044254wre.4
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:09:58 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id g32si2743810wra.44.2017.03.24.04.07.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 04:07:58 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id n11so10087059wma.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 04:07:57 -0700 (PDT)
Date: Fri, 24 Mar 2017 14:07:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: rmap: fix huge file mmap accounting in the memcg
 stats
Message-ID: <20170324110755.evvbeetf44h72p43@node.shutemov.name>
References: <20170322005111.3156-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170322005111.3156-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Mar 21, 2017 at 08:51:11PM -0400, Johannes Weiner wrote:
> Huge pages are accounted as single units in the memcg's "file_mapped"
> counter. Account the correct number of base pages, like we do in the
> corresponding node counter.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Sorry for missing that:

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Do we want it into stable?

Cc: <stable@vger.kernel.org>	[4.8+]

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
