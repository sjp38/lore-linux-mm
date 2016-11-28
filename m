Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 199C16B02D9
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:14:03 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so230674757pfg.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:14:03 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w31si27994854pla.3.2016.11.28.13.14.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 13:14:02 -0800 (PST)
Message-ID: <1480367641.3064.33.camel@linux.intel.com>
Subject: Re: [PATCH v3 0/8] mm/swap: Regular page swap optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Mon, 28 Nov 2016 13:14:01 -0800
In-Reply-To: <cover.1479252493.git.tim.c.chen@linux.intel.com>
References: <cover.1479252493.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Tue, 2016-11-15 at 15:47 -0800, Tim Chen wrote:
> Andrew,
> 
> It seems like there are no objections to this patch series so far.
> Can you help us get this patch series to be code reviewed in moreA 
> depth so it can be considered for inclusion to 4.10?
> Will appreciate if Mel, Johannes, Rik or others can take a look.


Hi Andrew,

Want to give you a ping to see if you can consider merging this series,
as there are no objections from anyone since its posting 2 weeks ago?

Thanks.

Ying & Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
