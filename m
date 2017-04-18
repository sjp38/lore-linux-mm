Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD0106B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 08:14:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a80so18707524wrc.19
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 05:14:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o26si7828204wra.182.2017.04.18.05.14.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 05:14:37 -0700 (PDT)
Date: Tue, 18 Apr 2017 14:14:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170418121434.GP22360@dhcp22.suse.cz>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
 <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
 <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, sgruszka@redhat.com

On Tue 18-04-17 20:49:20, Tetsuo Handa wrote:
> David Rientjes wrote:
[...]
> > Otherwise, I think this is a good direction.
> 
> So, here we got a conflict. Michal thinks this is a pointless code and
> David thinks this is a good direction. Michal, can you accept
> warn_alloc_stall()/warn_alloc_failed() separation?

This is eating way too much time considering how important it is. The
patch is not fixing any real bug so I do not think this is worth any
additional code. We could tweak around this code for another few months
which I definitely do not have time for that. If you want to fix a
_real_ bug, be explicit about it otherwise I do not see any reason to
change the code.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
