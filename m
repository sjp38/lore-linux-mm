Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47BE96B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 06:06:38 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b130so535039oii.4
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 03:06:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w132si5844739oib.514.2017.08.15.03.06.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 03:06:37 -0700 (PDT)
Message-Id: <201708151006.v7FA6SxD079619@www262.sakura.ne.jp>
Subject: Re: Re: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 =?ISO-2022-JP?B?b29tX3JlYXBlciByYWNlcyB3aXRoIHdyaXRlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 15 Aug 2017 19:06:28 +0900
References: <201708142251.v7EMp3j9081456@www262.sakura.ne.jp> <20170815084143.GB29067@dhcp22.suse.cz>
In-Reply-To: <20170815084143.GB29067@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 15-08-17 07:51:02, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > Were you able to reproduce with other filesystems?
> > 
> > Yes, I can reproduce this problem using both xfs and ext4 on 4.11.11-200.fc25.x86_64
> > on Oracle VM VirtualBox on Windows.
> 
> Just a quick question.
> http://lkml.kernel.org/r/201708112053.FIG52141.tHJSOQFLOFMFOV@I-love.SAKURA.ne.jp
> mentioned next-20170811 kernel and this one 4.11. Your original report
> as a reply to this thread
> http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp
> mentioned next-20170728. None of them seem to have this fix
> http://lkml.kernel.org/r/20170807113839.16695-3-mhocko@kernel.org so let
> me ask again. Have you seen an unexpected content written with that
> patch applied?

No. All non-zero non-0xFF values are without that patch applied.
I want to confirm that that patch actually fixes non-zero non-0xFF values
(so that we can have better patch description for that patch).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
