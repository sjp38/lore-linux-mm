Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 543BE6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 18:25:52 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so207121921pac.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 15:25:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d4si26422506pdj.10.2015.05.05.15.25.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 15:25:51 -0700 (PDT)
Date: Tue, 5 May 2015 15:25:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-Id: <20150505152549.037679566fad8c593df176ed@linux-foundation.org>
In-Reply-To: <20150505221329.GE2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<554030D1.8080509@hp.com>
	<5543F802.9090504@hp.com>
	<554415B1.2050702@hp.com>
	<20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
	<20150505104514.GC2462@suse.de>
	<20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
	<20150505221329.GE2462@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 5 May 2015 23:13:29 +0100 Mel Gorman <mgorman@suse.de> wrote:

> > Alternatively, the page allocator can go off and synchronously
> > initialize some pageframes itself.  Keep doing that until the
> > allocation attempt succeeds.
> > 
> 
> That was rejected during review of earlier attempts at this feature on
> the grounds that it impacted allocator fast paths. 

eh?  Changes are only needed on the allocation-attempt-failed path,
which is slow-path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
