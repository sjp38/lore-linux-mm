Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id E6D4F6B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 07:27:39 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i8so4612758qcq.11
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:27:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kl8si21430820lac.120.2014.12.23.04.27.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 04:27:36 -0800 (PST)
Date: Tue, 23 Dec 2014 13:27:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141223122735.GD28549@dhcp22.suse.cz>
References: <201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
 <20141222202511.GA9485@dhcp22.suse.cz>
 <201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
 <20141223095159.GA28549@dhcp22.suse.cz>
 <201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
 <201412232057.CID73463.FJFOtFLSOOVHQM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412232057.CID73463.FJFOtFLSOOVHQM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Tue 23-12-14 20:57:23, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > If such a delay is theoretically impossible, I'm OK with your patch.
> > 
> 
> Oops, I forgot to mention that task_unlock(p) should be called before
> put_task_struct(p), in case p->usage == 1 at put_task_struct(p).

True. It would be quite surprising to see p->mm != NULL if the OOM
killer was the only one to hold a reference to the task. So it shouldn't
make any difference AFAICS. It is a good practice to change that though.
Fixed.

[...]

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
