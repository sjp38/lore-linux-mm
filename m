Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF6696B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 09:16:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i137so3169808wmf.19
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 06:16:32 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id n6si3132257wmn.18.2017.04.28.06.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 06:16:31 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id u65so10853762wmu.3
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 06:16:30 -0700 (PDT)
Date: Fri, 28 Apr 2017 16:16:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm -v10 3/3] mm, THP, swap: Enable THP swap optimization
 only if has compound map
Message-ID: <20170428131628.vsiapdgm7e6yddsb@node.shutemov.name>
References: <20170425125658.28684-1-ying.huang@intel.com>
 <20170425125658.28684-4-ying.huang@intel.com>
 <20170425214618.GB6841@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425214618.GB6841@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 25, 2017 at 05:46:18PM -0400, Johannes Weiner wrote:
> On Tue, Apr 25, 2017 at 08:56:58PM +0800, Huang, Ying wrote:
> > From: Huang Ying <ying.huang@intel.com>
> > 
> > If there is no compound map for a THP (Transparent Huge Page), it is
> > possible that the map count of some sub-pages of the THP is 0.  So it
> > is better to split the THP before swapping out. In this way, the
> > sub-pages not mapped will be freed, and we can avoid the unnecessary
> > swap out operations for these sub-pages.
> > 
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> CC Kirill to double check the reasoning here

Looks good to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
