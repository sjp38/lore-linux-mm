Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDF666B02F2
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 02:36:10 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o36so46169238qtb.2
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 23:36:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x94si20935276qte.200.2017.04.24.23.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 23:36:10 -0700 (PDT)
Date: Tue, 25 Apr 2017 08:36:07 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
Message-ID: <20170425063606.GA8306@redhat.com>
References: <20170419132212.GA3514@redhat.com>
 <20170419133339.GI29789@dhcp22.suse.cz>
 <20170422081030.GA5476@redhat.com>
 <20170424084216.GB1739@dhcp22.suse.cz>
 <20170424130634.GA6267@redhat.com>
 <201704250006.EGD86943.HOFtOLFSOQVFJM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704250006.EGD86943.HOFtOLFSOQVFJM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org

On Tue, Apr 25, 2017 at 12:06:54AM +0900, Tetsuo Handa wrote:
> Stanislaw Gruszka wrote:
> > On Mon, Apr 24, 2017 at 10:42:17AM +0200, Michal Hocko wrote:
> > > If there
> > > is really a problem logs flooded by the allocation failures while using
> > > the guard page we should address it by a more strict ratelimiting.
> > 
> > Ok, make sense.
> 
> Stanislaw, can we apply updated version at
> http://lkml.kernel.org/r/1492525366-4929-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ?

The change is fine to me.

Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
