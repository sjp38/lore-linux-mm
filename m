Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0B16B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 02:42:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so62286083wmw.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 23:42:47 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id ju6si23617158wjb.182.2016.05.19.23.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 23:42:46 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id n129so67134093wmn.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 23:42:46 -0700 (PDT)
Date: Fri, 20 May 2016 08:42:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160520064244.GD19172@dhcp22.suse.cz>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160518141545.GI21654@dhcp22.suse.cz>
 <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
 <20160519065329.GA26110@dhcp22.suse.cz>
 <20160520015000.GA20132@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520015000.GA20132@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org

On Fri 20-05-16 03:50:01, Oleg Nesterov wrote:
> On 05/19, Michal Hocko wrote:
> >
> > Long term I
> > would like to to move this logic into the mm_struct, it would be just
> > larger surgery I guess.
> 
> Why we can't do this right now? Just another MMF_ flag set only once and
> never cleared.

It is more complicated and so more error prone. We have to sort out
shortcuts which get TIF_MEMDIE without killing first. And we have that
nasty "mm shared between independant processes" case there. I definitely
want to get to this after the merge window but the oom pile in the
Andrew's tree is quite large already. So this patch seems like a good
start to build on top.

If you feel that this step is not really worth it I can accept it of
course, this is an area where we do not have to hurry.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
