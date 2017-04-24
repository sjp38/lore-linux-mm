Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB896B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:07:16 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h18so72961192ita.9
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:07:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a21si756767oth.242.2017.04.24.08.07.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 08:07:14 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170419132212.GA3514@redhat.com>
	<20170419133339.GI29789@dhcp22.suse.cz>
	<20170422081030.GA5476@redhat.com>
	<20170424084216.GB1739@dhcp22.suse.cz>
	<20170424130634.GA6267@redhat.com>
In-Reply-To: <20170424130634.GA6267@redhat.com>
Message-Id: <201704250006.EGD86943.HOFtOLFSOQVFJM@I-love.SAKURA.ne.jp>
Date: Tue, 25 Apr 2017 00:06:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sgruszka@redhat.com, mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

Stanislaw Gruszka wrote:
> On Mon, Apr 24, 2017 at 10:42:17AM +0200, Michal Hocko wrote:
> > If there
> > is really a problem logs flooded by the allocation failures while using
> > the guard page we should address it by a more strict ratelimiting.
> 
> Ok, make sense.

Stanislaw, can we apply updated version at
http://lkml.kernel.org/r/1492525366-4929-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ?

> 
> Stanislaw
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
