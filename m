Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 224E86B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 09:46:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 94so534335wrb.10
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 06:46:18 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x76si3373532wrb.290.2017.03.24.06.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 06:46:16 -0700 (PDT)
Date: Fri, 24 Mar 2017 09:46:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: rmap: fix huge file mmap accounting in the memcg
 stats
Message-ID: <20170324134607.GA9994@cmpxchg.org>
References: <20170322005111.3156-1-hannes@cmpxchg.org>
 <20170324110755.evvbeetf44h72p43@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170324110755.evvbeetf44h72p43@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Mar 24, 2017 at 02:07:55PM +0300, Kirill A. Shutemov wrote:
> On Tue, Mar 21, 2017 at 08:51:11PM -0400, Johannes Weiner wrote:
> > Huge pages are accounted as single units in the memcg's "file_mapped"
> > counter. Account the correct number of base pages, like we do in the
> > corresponding node counter.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Sorry for missing that:
> 
> Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks!

> Do we want it into stable?
> 
> Cc: <stable@vger.kernel.org>	[4.8+]

Yep, that makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
