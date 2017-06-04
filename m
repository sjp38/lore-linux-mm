Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0156B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 11:05:39 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 46so6857863wru.0
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 08:05:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92si798233wrb.122.2017.06.04.08.05.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Jun 2017 08:05:37 -0700 (PDT)
Date: Sun, 4 Jun 2017 17:05:34 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170604150533.GA3500@dhcp22.suse.cz>
References: <20170601132808.GD9091@dhcp22.suse.cz>
 <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz>
 <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
 <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
 <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: xiyou.wangcong@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

On Sun 04-06-17 17:58:49, Tetsuo Handa wrote:
[...]
> > As I already mentioned in my original report, I know there are at least
> > two similar warnings reported before:
> >
> > https://lkml.org/lkml/2016/12/13/529
> > https://bugzilla.kernel.org/show_bug.cgi?id=192981
> >
> > I don't see any fix, nor I see they are similar to mine.
> 
> No means for analyzing, no plan for fixing the problems.

Stop this bullshit Tetsuo! Seriously, you are getting over the line!
Nobody said we do not care. In order to do something about that we need
to get further and relevant information. The first and the most
important one is whether this is reproducible with the _clean_ vanilla
kernel. If yes then reproduction steps including the system dependent
ones would help us as well. If we know that we can start building
a more comprehensive picture of what is going on. Unlike you I do not
want to jump into "this must be print" conclusion.

But stop this unjustified claims.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
