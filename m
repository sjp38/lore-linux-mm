Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B338C6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 05:04:35 -0400 (EDT)
Received: by fxg9 with SMTP id 9so177008fxg.14
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 02:04:29 -0700 (PDT)
Date: Thu, 4 Aug 2011 11:04:25 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] percpu: rename pcpu_mem_alloc to pcpu_mem_zalloc
Message-ID: <20110804090425.GA25100@htj.dyndns.org>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-4-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312427390-20005-4-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, Aug 04, 2011 at 11:09:50AM +0800, Bob Liu wrote:
> Currently pcpu_mem_alloc() is implemented always return zeroed memory.
> So rename it to make user like pcpu_get_pages_and_bitmap() know don't reinit it.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

applied to percpu#for-3.2, thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
