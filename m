Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 019226B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 13:38:00 -0500 (EST)
Received: by wmdw130 with SMTP id w130so252205535wmd.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 10:37:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w189si5764991wmd.3.2015.11.19.10.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 10:37:58 -0800 (PST)
Date: Thu, 19 Nov 2015 13:37:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [kbuild-all] [patch -mm] mm, vmalloc: remove VM_VPAGES
Message-ID: <20151119183745.GA2555@cmpxchg.org>
References: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
 <alpine.DEB.2.10.1511181659290.8399@chino.kir.corp.google.com>
 <20151119113300.GA22395@wfg-t540p.sh.intel.com>
 <201511192123.DHI75684.FFHOOQSVMLOFJt@I-love.SAKURA.ne.jp>
 <20151119123546.GA25179@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151119123546.GA25179@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <lkp@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org, akpm@linux-foundation.org, kbuild-all@01.org, linux-kernel@vger.kernel.org

Hi Fengguang,

On Thu, Nov 19, 2015 at 08:35:46PM +0800, Fengguang Wu wrote:
> 
>         git://git.cmpxchg.org/linux-mmotm.git
> 
> I'll teach the robot to use it instead of linux-next for [-mm] patches.

Yup, that seems like a more suitable base.

But you might even consider putting them on top of linux-mmots.git,
which is released more frequently than mmotm. Not sure what other MM
hackers do, but I tend to develop against mmots, and there could be
occasional breakage when dependencies haven't yet trickled into mmotm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
