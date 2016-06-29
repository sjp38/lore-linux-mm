Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3AAB6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 10:19:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a2so37312962lfe.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:19:56 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k2si5141448wjs.220.2016.06.29.07.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 07:19:54 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 187so14737718wmz.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:19:54 -0700 (PDT)
Date: Wed, 29 Jun 2016 16:19:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160629141953.GC27153@dhcp22.suse.cz>
References: <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629083314.GA27153@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

OK, so this is what I have on top of [1]. I still haven't tested it but
at least added a changelog to have some reasoning for the change. If
this looks OK and passes my testing - which would be tricky anyway
because hitting those rare corner cases is quite hard - then the next
step would be to fix the race between suspend and oom_killer_disable
currently worked around by 74070542099c in a more robust way. We can
also start thinking to use TIF_MEMDIE only for the access to memory
reserves to oom victims which actually need to allocate and decouple the
current double meaning.

I completely understand a resistance to adding new stuff to the
signal_struct but this seems like worth it. I would like to have a
stable and existing mm for that purpose but that sounds like a more long
term plan than something we can do right away.

Thoughts?

[1] http://lkml.kernel.org/r/1467201562-6709-1-git-send-email-mhocko@kernel.org
---
