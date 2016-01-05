Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB986B0003
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 12:38:38 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id b14so40325456wmb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 09:38:38 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id hn7si73468643wjc.227.2016.01.05.09.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 09:38:37 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id b14so40324865wmb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 09:38:37 -0800 (PST)
Date: Tue, 5 Jan 2016 18:38:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH] sysrq: ensure manual invocation of the OOM killer
 under OOM livelock
Message-ID: <20160105173835.GA23326@dhcp22.suse.cz>
References: <201512301533.JDJ18237.QOFOMVSFtHOJLF@I-love.SAKURA.ne.jp>
 <20160105162246.GH15324@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105162246.GH15324@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 05-01-16 17:22:46, Michal Hocko wrote:
> I guess this is not only sysrq+f
> specific though. What about emergency reboot or manual crash invocation?

I am a fool. For some reason I thought that em. reboot and the crash
invocation rely on the WQ as well. They are not though. So scratch this
and sorry about the confusion.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
