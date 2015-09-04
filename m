Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 47A126B0255
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 10:06:03 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so23883370wic.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 07:06:02 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id p12si5042424wiv.60.2015.09.04.07.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 07:06:02 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so23943310wic.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 07:06:01 -0700 (PDT)
Date: Fri, 4 Sep 2015 16:05:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] android, lmk: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150904140559.GD8220@dhcp22.suse.cz>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
 <201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
 <20150903010620.GC31349@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150903010620.GC31349@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org

On Wed 02-09-15 18:06:20, Greg KH wrote:
[...]
> And if we aren't taking patch 1/2, I guess this one isn't needed either?

Unlike the patch1 which was pretty much cosmetic this fixes a real
issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
