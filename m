Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A56B6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:43:30 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 187so15833011ito.14
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 07:43:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v125si7044707itc.26.2017.03.29.07.43.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 07:43:29 -0700 (PDT)
Subject: Re: [PATCH v3] mm: Allow calling vfree() from non-schedulable context.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<0065385b-8cf9-aec6-22bb-9e6d21501a8c@virtuozzo.com>
	<20170329114705.GL27994@dhcp22.suse.cz>
In-Reply-To: <20170329114705.GL27994@dhcp22.suse.cz>
Message-Id: <201703292341.AJG51076.JFSFOLOOMQHFtV@I-love.SAKURA.ne.jp>
Date: Wed, 29 Mar 2017 23:41:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, aryabinin@virtuozzo.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de

Michal Hocko wrote:
> On Wed 29-03-17 14:36:10, Andrey Ryabinin wrote:
> [...]
> > So I just get a better idea. How about just always deferring
> > __purge_vmap_area_lazy()?
> 
> I didn't get to look closer but from the high level POV this makes a lot
> of sense. __purge_vmap_area_lazy shouldn't be called all that often that
> the deferred mode would matter.

I tested this change and confirmed that warnings went away.
This change is simple enough to send to 4.10-stable and 4.11-rc.
If you are OK with this change, I'm OK with this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
