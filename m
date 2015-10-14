Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 315366B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:07:06 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so41572342obb.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 08:07:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ca19si4919105obb.58.2015.10.14.08.07.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Oct 2015 08:07:05 -0700 (PDT)
Subject: Re: Silent hang up caused by pages being not scanned?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151013133225.GA31034@dhcp22.suse.cz>
	<201510140119.FGC17641.FSOHMtQOFLJOVF@I-love.SAKURA.ne.jp>
	<20151014132248.GH28333@dhcp22.suse.cz>
	<201510142338.IEE21387.LFHSQVtMOFOFJO@I-love.SAKURA.ne.jp>
	<20151014145938.GI28333@dhcp22.suse.cz>
In-Reply-To: <20151014145938.GI28333@dhcp22.suse.cz>
Message-Id: <201510150006.IID90402.FHtSOJOVQFMOFL@I-love.SAKURA.ne.jp>
Date: Thu, 15 Oct 2015 00:06:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> On Wed 14-10-15 23:38:00, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > Why hasn't balance_dirty_pages throttled writers and allowed them to
> > > make the whole LRU dirty? What is your dirty{_background}_{ratio,bytes}
> > > configuration on that system.
> > 
> > All values are defaults of plain CentOS 7 installation.
> 
> So this is 3.10 kernel, right?

The userland is CentOS 7 but the kernel is linux-next-20151009.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
