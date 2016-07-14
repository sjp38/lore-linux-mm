Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFC5C6B026E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 18:04:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so180134874pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 15:04:34 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id f8si233737pff.71.2016.07.14.15.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 15:04:33 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id dx3so32534367pab.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 15:04:33 -0700 (PDT)
Date: Thu, 14 Jul 2016 15:04:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <201607150640.GEB78167.VOFSFHOLMtJOFQ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1607141504110.72383@chino.kir.corp.google.com>
References: <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1607141324290.68666@chino.kir.corp.google.com> <201607150640.GEB78167.VOFSFHOLMtJOFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mpatocka@redhat.com, mhocko@kernel.org, okozina@redhat.com, jmarchan@redhat.com, skozina@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Jul 2016, Tetsuo Handa wrote:

> Whether the OOM reaper will free some memory no longer matters. Instead,
> whether the OOM reaper will let the OOM killer select next OOM victim matters.
> 
> Are you aware that the OOM reaper will let the OOM killer select next OOM
> victim (currently by clearing TIF_MEMDIE)? Clearing TIF_MEMDIE in 4.6 occurred
> only when OOM reaping succeeded. But we are going to change the OOM reaper
> always clear TIF_MEMDIE in 4.8 (or presumably change the OOM killer not to
> depend on TIF_MEMDIE) so that the OOM reaper guarantees that the OOM killer
> always selects next OOM victim.
> 

That's cute, I'll have to look into those patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
