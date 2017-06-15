Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 14B6C6B02B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:28:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d191so14565805pga.15
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 17:28:20 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id 1si1030047pgu.95.2017.06.14.17.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 17:28:19 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id s66so8016278pfs.1
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 17:28:19 -0700 (PDT)
Date: Wed, 14 Jun 2017 17:28:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Sleeping BUG in khugepaged for i586
In-Reply-To: <20170612062918.GA4145@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1706141726200.105832@chino.kir.corp.google.com>
References: <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net> <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz> <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com> <20170608144831.GA19903@dhcp22.suse.cz> <20170608170557.GA8118@bombadil.infradead.org>
 <20170608201822.GA5535@dhcp22.suse.cz> <20170608203046.GB5535@dhcp22.suse.cz> <alpine.DEB.2.10.1706091537020.66176@chino.kir.corp.google.com> <20170610080941.GA12347@dhcp22.suse.cz> <alpine.DEB.2.10.1706111621330.36347@chino.kir.corp.google.com>
 <20170612062918.GA4145@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 12 Jun 2017, Michal Hocko wrote:

> > These are not soft lockups, these are need_resched warnings.  We monitor 
> > how long need_resched has been set and when a thread takes an excessive 
> > amount of time to reschedule after it has been set.  A loop of 512 pages 
> > with ptl contention and doing {clear,copy}_user_highpage() shows that 
> > need_resched can sit without scheduling for an excessive amount of time.
> 
> How much is excessive here?

We monitor anything that holds the cpu for more than 1/20th of a second, 
but this specific occurrence has been observed for ~1/8th.  The majority 
of mm/ is quite good in this regard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
