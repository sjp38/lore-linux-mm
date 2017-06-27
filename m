Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 738C26B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:39:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p15so25292901pgs.7
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:39:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u19si1961229plj.4.2017.06.27.04.39.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 04:39:31 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170626130346.26314-1-mhocko@kernel.org>
	<201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
	<20170627112650.GK28072@dhcp22.suse.cz>
In-Reply-To: <20170627112650.GK28072@dhcp22.suse.cz>
Message-Id: <201706272039.HGG51520.QOMHFVOFtOSJFL@I-love.SAKURA.ne.jp>
Date: Tue, 27 Jun 2017 20:39:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > I wonder why you prefer timeout based approach. Your patch will after all
> > set MMF_OOM_SKIP if operations between down_write() and up_write() took
> > more than one second.
> 
> if we reach down_write then we have unmapped the address space in
> exit_mmap and oom reaper cannot do much more.

So, by the time down_write() is called, majority of memory is already released, isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
