Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B86E66B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 16:36:30 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id ho8so19981582pac.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 13:36:30 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id y29si7338926pfa.174.2016.02.24.13.36.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 13:36:29 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id e127so19822007pfe.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 13:36:29 -0800 (PST)
Date: Wed, 24 Feb 2016 13:36:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they
 are OOM-unkillable.
In-Reply-To: <20160224100520.GB20863@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1602241334470.5955@chino.kir.corp.google.com>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com> <20160218080909.GA18149@dhcp22.suse.cz> <alpine.DEB.2.10.1602221701170.4688@chino.kir.corp.google.com>
 <20160223123457.GC14178@dhcp22.suse.cz> <alpine.DEB.2.10.1602231420590.744@chino.kir.corp.google.com> <20160224100520.GB20863@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 24 Feb 2016, Michal Hocko wrote:

> Hmm, is it really helpful though? What would you deduce from seeing a
> large rss an OOM_SCORE_ADJ_MIN task? Misconfigured system? There must
> have been a reason to mark the task that way in the first place so you
> can hardly do anything about it. Moreover you can deduce the same from
> the available information.
> 

Users run processes that are vital to the machine with OOM_SCORE_ADJ_MIN.  
This does not make them immune to having memory leaks that caused the oom 
condition, and identifying that has triaged many bugs in the past.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
