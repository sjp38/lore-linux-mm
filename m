Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4C62C6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 13:15:21 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so30348108pac.2
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 10:15:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dn2si5228056pbb.210.2015.09.04.10.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 10:15:20 -0700 (PDT)
Date: Fri, 4 Sep 2015 10:15:19 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] android, lmk: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150904171519.GA5537@kroah.com>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
 <201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
 <20150903010620.GC31349@kroah.com>
 <20150904140559.GD8220@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904140559.GD8220@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org

On Fri, Sep 04, 2015 at 04:05:59PM +0200, Michal Hocko wrote:
> On Wed 02-09-15 18:06:20, Greg KH wrote:
> [...]
> > And if we aren't taking patch 1/2, I guess this one isn't needed either?
> 
> Unlike the patch1 which was pretty much cosmetic this fixes a real
> issue.

Ok, then it would be great to get this in a format that I can apply it
in :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
