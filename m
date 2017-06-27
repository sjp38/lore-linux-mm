Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 055686B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:03:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so24603751wry.4
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 05:03:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t187si2401795wmf.184.2017.06.27.05.03.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 05:03:20 -0700 (PDT)
Date: Tue, 27 Jun 2017 14:03:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170627120317.GL28072@dhcp22.suse.cz>
References: <20170626130346.26314-1-mhocko@kernel.org>
 <201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
 <20170627112650.GK28072@dhcp22.suse.cz>
 <201706272039.HGG51520.QOMHFVOFtOSJFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706272039.HGG51520.QOMHFVOFtOSJFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 27-06-17 20:39:28, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > I wonder why you prefer timeout based approach. Your patch will after all
> > > set MMF_OOM_SKIP if operations between down_write() and up_write() took
> > > more than one second.
> > 
> > if we reach down_write then we have unmapped the address space in
> > exit_mmap and oom reaper cannot do much more.
> 
> So, by the time down_write() is called, majority of memory is already released, isn't it?

In most cases yes. To be put it in other words. By the time exit_mmap
takes down_write there is nothing more oom reaper could reclaim.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
