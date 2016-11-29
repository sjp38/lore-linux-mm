Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF14C6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:50:02 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so461523798pga.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:50:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h5si57495255pgg.22.2016.11.29.13.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 13:50:01 -0800 (PST)
Date: Tue, 29 Nov 2016 13:50:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/8] mm/swap: Regular page swap optimizations
Message-Id: <20161129135012.ec4f6fd238022b76943e9f43@linux-foundation.org>
In-Reply-To: <1480367641.3064.33.camel@linux.intel.com>
References: <cover.1479252493.git.tim.c.chen@linux.intel.com>
	<1480367641.3064.33.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Mon, 28 Nov 2016 13:14:01 -0800 Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Tue, 2016-11-15 at 15:47 -0800, Tim Chen wrote:
> > Andrew,
> > 
> > It seems like there are no objections to this patch series so far.
> > Can you help us get this patch series to be code reviewed in more__
> > depth so it can be considered for inclusion to 4.10?
> > Will appreciate if Mel, Johannes, Rik or others can take a look.
> 
> 
> Hi Andrew,
> 
> Want to give you a ping to see if you can consider merging this series,
> as there are no objections from anyone since its posting 2 weeks ago?

Well, you did say "for 4.10", with which I agree.  So I have them
buffered for processing around the 4.10-rc1 timeframe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
