Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8C806B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 13:40:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id u5so1072659630pgi.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 10:40:43 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s186si76702205pgb.6.2017.01.05.10.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 10:40:43 -0800 (PST)
Message-ID: <1483641642.2833.10.camel@linux.intel.com>
Subject: Re: [PATCH v3 0/8] mm/swap: Regular page swap optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 05 Jan 2017 10:40:42 -0800
In-Reply-To: <20161129135012.ec4f6fd238022b76943e9f43@linux-foundation.org>
References: <cover.1479252493.git.tim.c.chen@linux.intel.com>
	 <1480367641.3064.33.camel@linux.intel.com>
	 <20161129135012.ec4f6fd238022b76943e9f43@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Tue, 2016-11-29 at 13:50 -0800, Andrew Morton wrote:
> On Mon, 28 Nov 2016 13:14:01 -0800 Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > 
> > On Tue, 2016-11-15 at 15:47 -0800, Tim Chen wrote:
> > > 
> > > Andrew,
> > > 
> > > It seems like there are no objections to this patch series so far.
> > > Can you help us get this patch series to be code reviewed in more__
> > > depth so it can be considered for inclusion to 4.10?
> > > Will appreciate if Mel, Johannes, Rik or others can take a look.
> > 
> > Hi Andrew,
> > 
> > Want to give you a ping to see if you can consider merging this series,
> > as there are no objections from anyone since its posting 2 weeks ago?
> Well, you did say "for 4.10", with which I agree.A A So I have them
> buffered for processing around the 4.10-rc1 timeframe.
> 

Andrew,

We've updated the patchset to v4. A 

Is there anything we need to modify for the patch set to beA 
picked up for mm tree?

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
