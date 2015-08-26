Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id B621F6B0256
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 10:31:24 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so120057574qkb.2
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 07:31:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n63si24213049qkh.4.2015.08.26.07.31.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 07:31:23 -0700 (PDT)
Date: Wed, 26 Aug 2015 16:28:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting
	TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150826142851.GA30481@redhat.com>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp> <20150826141233.GI25196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150826141233.GI25196@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Hi Michal,

On 08/26, Michal Hocko wrote:
>
> I cannot seem to find any explicit note about task_lock vs. signal
> nesting nor task_lock() anywhere in kernel/signal.c so I rather ask. Can
> we call do_send_sig_info with task_lock held?

Yes.

Simply because task_lock() doesn't disable irqs and (unfortunately ;)
we do send the signals from interrupts.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
