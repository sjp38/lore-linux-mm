Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5076B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 07:01:25 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id d184so14518230ybh.4
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 04:01:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w190si34270991oia.229.2017.01.06.04.01.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 04:01:24 -0800 (PST)
Subject: Re: [Bug 190351] New: OOM but no swap used
References: <bug-190351-27@https.bugzilla.kernel.org/>
 <20170105114611.8b0fa5d3ec779e8a71b3973c@linux-foundation.org>
 <20170106083125.GC5556@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <da790d46-e52f-949f-5132-0834e64c669e@I-love.SAKURA.ne.jp>
Date: Fri, 6 Jan 2017 21:00:29 +0900
MIME-Version: 1.0
In-Reply-To: <20170106083125.GC5556@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rtc@helen.plasma.xg8.de
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 2017/01/06 17:31, Michal Hocko wrote:
>>> slab_reclaimable:732236kB slab_unreclaimable:70736kB kernel_stack:2560kB
> 
> slab consumption is really high. It has eaten a majority of the lowmem.
> I would focus on who is eating that memory. Try to watch /proc/slabinfo
> for anomalies.
> 

Maybe you can use https://sourceware.org/systemtap/examples/#memory/vm.tracepoints.stp .
Absolutely latest kernels might need systemtap built from source git tree at
https://sourceware.org/systemtap/getinvolved.html , but compilation is not difficult at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
