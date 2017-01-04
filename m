Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E84E6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 12:16:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so1595939531pgc.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 09:16:19 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b1si73094157pld.129.2017.01.04.09.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 09:16:18 -0800 (PST)
Message-ID: <1483550177.3064.104.camel@linux.intel.com>
Subject: Re: [LSF/MM TOPIC] plans for future swap changes
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 04 Jan 2017 09:16:17 -0800
In-Reply-To: <20170104064024.GA3676@cmpxchg.org>
References: <20161228145732.GE11470@dhcp22.suse.cz>
	 <20170104064024.GA3676@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Shaohua Li <shli@fb.com>


> 
> > 
> > 3) optimizations for the swap out paths - Tim Chen and other guys from
> > A A A Intel are already working on this. I didn't get time to review this
> > A A A closely - mostly because I am not closely familiar with the swapout
> > A A A code and it takes quite some time to get into all subtle details.
> > A A A I mainly interested in what are the plans in this area and how they
> > A A A should be coordinated with other swap related changes

We are also planning on discussing this topic at the mm summit, if the
patch series have not yet got into mainline, plus a couple
of others swap related stuff. A I'll be sending out our proposal separately.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
