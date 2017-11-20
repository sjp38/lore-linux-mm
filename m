Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 947D66B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 05:57:31 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id d21so2708393ioe.3
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 02:57:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m84si8857871ioo.133.2017.11.20.02.57.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 02:57:29 -0800 (PST)
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171117173521.GA21692@infradead.org>
	<20171120092526.llj2q3lqbbxwn4g4@dhcp22.suse.cz>
	<20171120093309.GA19627@infradead.org>
	<20171120094237.z6h3kx3ne5ld64pl@dhcp22.suse.cz>
	<20171120104129.GA25042@infradead.org>
In-Reply-To: <20171120104129.GA25042@infradead.org>
Message-Id: <201711201956.IIB86978.OFMVFFOJLtOSHQ@I-love.SAKURA.ne.jp>
Date: Mon, 20 Nov 2017 19:56:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@infradead.org, mhocko@kernel.org
Cc: minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com

Christoph Hellwig wrote:
> On Mon, Nov 20, 2017 at 10:42:37AM +0100, Michal Hocko wrote:
> > The patch has been dropped because allnoconfig failed to compile back
> > then http://lkml.kernel.org/r/CAP=VYLr0rPWi1aeuk4w1On9CYRNmnEWwJgGtaX=wEvGaBURtrg@mail.gmail.com
> > I have problem to find the follow up discussion though. The main
> > argument was that SRC is not generally available and so the core
> > kernel should rely on it.
> 
> Paul,
> 
> isthere any good reason to not use SRCU in the core kernel and
> instead try to reimplement it using atomic counters?

CONFIG_SRCU was added in order to save system size. There are users who run Linux on very
small systems ( https://www.elinux.org/images/5/52/Status-of-embedded-Linux-2017-09-JJ62.pdf ).

Also, atomic counters are not mandatory for shrinker case; e.g.
http://lkml.kernel.org/r/201711161956.EBF57883.QFFMOLOVSOHJFt@I-love.SAKURA.ne.jp .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
