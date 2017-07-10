Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1A7B6B0292
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 01:07:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 13so105946557pgg.8
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 22:07:34 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id k22si7149529pgf.314.2017.07.09.22.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 22:07:33 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id u62so43305847pgb.3
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 22:07:33 -0700 (PDT)
Date: Mon, 10 Jul 2017 14:07:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Message-ID: <20170710050740.GA7706@jagdpanzerIV.localdomain>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain>
 <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky.work@gmail.com, sergey.senozhatsky@gmail.com, pmladek@suse.com, mhocko@kernel.org, pavel@ucw.cz, rostedt@goodmis.org, andi@lisas.de, jack@suse.cz, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, daniel.vetter@ffwll.ch

Hello,

On (07/08/17 22:30), Tetsuo Handa wrote:
> Hmm... should we consider addressing console_sem problem before
> introducing printing kernel thread and offloading to that kernel
> thread?

printk-kthread addresses a completely different set of problems.

console_sem is hard to fix quickly, because it involves rework of
tty/fbcon/drm/etc/etc/etc sub-systems; printk is the easiest part
here...

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
