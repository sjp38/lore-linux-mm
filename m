Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85ABE6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:27:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v11so11628063wri.13
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:27:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si3984796wrc.540.2018.04.04.08.27.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 08:27:15 -0700 (PDT)
Date: Wed, 4 Apr 2018 17:27:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404152713.GM6312@dhcp22.suse.cz>
References: <20180403135607.GC5501@dhcp22.suse.cz>
 <20180403101753.3391a639@gandalf.local.home>
 <20180403161119.GE5501@dhcp22.suse.cz>
 <20180403185627.6bf9ea9b@gandalf.local.home>
 <20180404062039.GC6312@dhcp22.suse.cz>
 <20180404085901.5b54fe32@gandalf.local.home>
 <20180404141052.GH6312@dhcp22.suse.cz>
 <20180404102527.763250b4@gandalf.local.home>
 <20180404144255.GK6312@dhcp22.suse.cz>
 <20180404110442.4cf904ae@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404110442.4cf904ae@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed 04-04-18 11:04:42, Steven Rostedt wrote:
[...]
> I'm not looking for perfect. In fact, I love what si_mem_available()
> gives me now! Sure, it can say "there's enough memory" even if I can't
> use it. Because most of the OOM allocations that happen with increasing
> the size of the ring buffer isn't due to "just enough memory
> allocated", but it's due to "trying to allocate crazy amounts of
> memory".  That's because it does the allocation one page at a time, and
> if you try to allocate crazy amounts of memory, it will allocate all
> memory before it fails. I don't want that. I want crazy allocations to
> fail from the start. A "maybe this will allocate" is fine even if it
> will end up causing an OOM.

OK, fair enough. It's your code ;) I would recommend using the
oom_origin thingy to reduce the immediate damage and to have a clear
culprit so that I do not have to scratch my head why we see an OOM
report with a lot of unaccounted memory...

I am afraid I cannot help you much more though.
-- 
Michal Hocko
SUSE Labs
