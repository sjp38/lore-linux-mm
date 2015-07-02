Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2539003C7
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 22:28:46 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so43178355qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:28:46 -0700 (PDT)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id 79si4745385qhw.4.2015.07.01.19.28.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 19:28:45 -0700 (PDT)
Received: by qkei195 with SMTP id i195so43234410qke.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:28:45 -0700 (PDT)
Date: Wed, 1 Jul 2015 22:28:43 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 39/51] writeback: make writeback_in_progress() take
 bdi_writeback instead of backing_dev_info
Message-ID: <20150702022843.GI26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-40-git-send-email-tj@kernel.org>
 <20150701074708.GZ7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701074708.GZ7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello, Jan.

On Wed, Jul 01, 2015 at 09:47:08AM +0200, Jan Kara wrote:
> BTW: It would have been easier for me to review this if e.g. a move from
> bdi to wb parameter was split among less patches. The intermediate state
> where some functions call partly bdi and party wb functions is strange and
> it always makes me go search in the series whether the other part of the
> function gets converted and whether they play well together...

Similar argument.  When reviewing big picture transitions, it *could*
be easier to have larger lumps but I believe that's not necessarily
because reviewing itself becomes easier but more because it becomes
easier to skip what's uninteresting like actually verifying each
change.  Another aspect is that some of the changes are spread out.
When each patch modifies one part, it's clear that all changes in the
patch belong to that specific part; however, in larger lumps, there
usually are a number of stragglers across the changes and associating
them with other parts aren't necessarily trivial.  This happens with
patch descrption too.  It becomes easier to slip in, intentionally or
by mistake, unrelated changes without explaining what's going on.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
