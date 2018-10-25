Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2266B0003
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 03:11:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v18-v6so4086068edq.23
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 00:11:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8-v6si3048774eje.206.2018.10.25.00.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 00:11:42 -0700 (PDT)
Date: Thu, 25 Oct 2018 09:11:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Use timeout based back off.
Message-ID: <20181025071140.GK18839@dhcp22.suse.cz>
References: <1540033021-3258-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1810221406400.120157@chino.kir.corp.google.com>
 <20181024155454.4e63191fbfaa0441f2e62f56@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024155454.4e63191fbfaa0441f2e62f56@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, yang.s@alibaba-inc.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed 24-10-18 15:54:54, Andrew Morton wrote:
[...]
> There has been a lot of heat and noise and confusion and handwaving in
> all of this.  What we're crying out for is simple testcases which
> everyone can run.  Find a problem, write the testcase, distribute that.
> Develop a solution for that testcase then move on to the next one.

Agreed! It is important for these test to represent some reasonable
workloads though.
-- 
Michal Hocko
SUSE Labs
