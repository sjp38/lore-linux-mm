Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37D686B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:28:06 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u142so8362013oia.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:28:06 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0013.hostedemail.com. [216.40.44.13])
        by mx.google.com with ESMTPS id v123si28722883itg.41.2016.07.27.11.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 11:28:05 -0700 (PDT)
Date: Wed, 27 Jul 2016 14:28:00 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
Message-ID: <20160727142800.14bd93d0@gandalf.local.home>
In-Reply-To: <1469643382.10218.20.camel@surriel.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	<6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
	<20160727163351.GC21859@dhcp22.suse.cz>
	<1469643382.10218.20.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Wed, 27 Jul 2016 14:16:22 -0400
Rik van Riel <riel@surriel.com> wrote:


> As for the function tracer, I wish I had known
> about that!

The kernel (and just the tracing infrastructure) is too big to know
everything that is there.

> 
> That looks like it should provide the info that
> Janani needs to write her memory allocation latency
> tracing script/tool.
> 
> As her Outreachy mentor, I should probably apologize
> for potentially having sent her down the wrong path
> with tracepoints, and I hope it has been an
> educational trip at least :)
> 

No, it was a perfect example of how we work, and I don't see this as a
wrong path. It's a good learning tool because that patch is exactly
what someone wanting to do a specific task will probably do as their
first attempt. There should be no shame in sending out a patch and have
feedback on another way to accomplish the same thing that doesn't
impact the system as much.

As stated above, the kernel is too big to know everything that needs to
be done. Thus, kernel development is really about trial and error. Send
out what works for you, and then take feedback from those that know
their system better than you to make your patch better.

That's how the workflow should happen on a daily basis. And is exactly
how I operate. There's lots of patches that I send out to other
maintainers that end up being something complete different because I
don't know their systems as well as they do.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
