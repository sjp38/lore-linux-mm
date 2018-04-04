Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4947E6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:10:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u13so11493500wre.1
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:10:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s38si3776575wrc.420.2018.04.04.07.10.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 07:10:56 -0700 (PDT)
Date: Wed, 4 Apr 2018 16:10:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404141052.GH6312@dhcp22.suse.cz>
References: <20180403121614.GV5501@dhcp22.suse.cz>
 <20180403082348.28cd3c1c@gandalf.local.home>
 <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz>
 <20180403101753.3391a639@gandalf.local.home>
 <20180403161119.GE5501@dhcp22.suse.cz>
 <20180403185627.6bf9ea9b@gandalf.local.home>
 <20180404062039.GC6312@dhcp22.suse.cz>
 <20180404085901.5b54fe32@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404085901.5b54fe32@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed 04-04-18 08:59:01, Steven Rostedt wrote:
[...]
> +       /*
> +        * Check if the available memory is there first.
> +        * Note, si_mem_available() only gives us a rough estimate of available
> +        * memory. It may not be accurate. But we don't care, we just want
> +        * to prevent doing any allocation when it is obvious that it is
> +        * not going to succeed.
> +        */
> +       i = si_mem_available();
> +       if (i < nr_pages)
> +               return -ENOMEM;
> +
> 
> Better?

I must be really missing something here. How can that work at all for
e.g. the zone_{highmem/movable}. You will get false on the above tests
even when you will have hard time to allocate anything from your
destination zones.
-- 
Michal Hocko
SUSE Labs
