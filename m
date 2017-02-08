Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 422366B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 04:24:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so186917002pgi.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 01:24:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g76si6611341pfb.262.2017.02.08.01.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 01:24:58 -0800 (PST)
Date: Wed, 8 Feb 2017 10:24:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170208092451.GU6515@twins.programming.kicks-ass.net>
References: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
 <20170203145548.GC19325@dhcp22.suse.cz>
 <201702051943.CFB35412.OOSJVtLFOFQHMF@I-love.SAKURA.ne.jp>
 <20170206103918.GD3097@dhcp22.suse.cz>
 <20170207211211.GB19351@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207211211.GB19351@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Tue, Feb 07, 2017 at 10:12:12PM +0100, Michal Hocko wrote:
> This is moot - http://lkml.kernel.org/r/20170207201950.20482-1-mhocko@kernel.org

Thanks! I was just about to go stare at it in more detail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
