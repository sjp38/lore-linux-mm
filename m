Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7096B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 04:38:27 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so37453679wid.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 01:38:26 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id o14si15091336wiw.9.2015.08.27.01.38.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 01:38:25 -0700 (PDT)
Received: by wijn1 with SMTP id n1so47961091wij.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 01:38:25 -0700 (PDT)
Date: Thu, 27 Aug 2015 10:38:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150827083822.GC14367@dhcp22.suse.cz>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
 <20150826141233.GI25196@dhcp22.suse.cz>
 <20150826142851.GA30481@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150826142851.GA30481@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 26-08-15 16:28:52, Oleg Nesterov wrote:
> Hi Michal,
> 
> On 08/26, Michal Hocko wrote:
> >
> > I cannot seem to find any explicit note about task_lock vs. signal
> > nesting nor task_lock() anywhere in kernel/signal.c so I rather ask. Can
> > we call do_send_sig_info with task_lock held?
> 
> Yes.
> 
> Simply because task_lock() doesn't disable irqs and (unfortunately ;)
> we do send the signals from interrupts.

Good point. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
