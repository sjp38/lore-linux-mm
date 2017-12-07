Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A93D6B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 03:45:00 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t15so3043611wmh.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 00:44:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c15si1319230wra.5.2017.12.07.00.44.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 00:44:58 -0800 (PST)
Date: Thu, 7 Dec 2017 09:44:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171207084457.GD20234@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
 <20171206090019.GE16386@dhcp22.suse.cz>
 <201712070720.vB77KlBQ009754@www262.sakura.ne.jp>
 <20171207082801.GB20234@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207082801.GB20234@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 07-12-17 09:28:01, Michal Hocko wrote:
[...]
> oom_reaper		oom_victim		task
> 						mmget_not_zero
> 			exit_mmap

bleh, this should have been do_exit

> 			  mmput
> __oom_reap_task_mm				mmput
>   						  __mmput
> 						    exit_mmap
> 						      remove_vma
>   unmap_page_range
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
