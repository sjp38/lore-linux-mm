Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id EB0239003CE
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 23:06:28 -0400 (EDT)
Received: by qkei195 with SMTP id i195so43654843qke.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:06:28 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id 139si4811210qhh.63.2015.07.01.20.06.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 20:06:28 -0700 (PDT)
Received: by qkbp125 with SMTP id p125so43572426qkb.2
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 20:06:28 -0700 (PDT)
Date: Wed, 1 Jul 2015 23:06:24 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 44/51] writeback: implement bdi_wait_for_completion()
Message-ID: <20150702030624.GM26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-45-git-send-email-tj@kernel.org>
 <20150701160437.GG7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701160437.GG7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello, Jan.

On Wed, Jul 01, 2015 at 06:04:37PM +0200, Jan Kara wrote:
> I'd find it better to extend completions to allow doing what you need. It
> isn't that special. It seems it would be enough to implement
> 
> void wait_for_completions(struct completion *x, int n);
> 
> where @n is the number of completions to wait for. And the implementation
> can stay as is, only in do_wait_for_common() we change checks for x->done ==
> 0 to "x->done < n". That's about it...

I don't know.  While I agree that it'd be nice to have a generic event
count & trigger mechanism in the kernel, I don't think extending
completion is a good idea - the count then works both ways as the
event counter && listener counter and effectively becomes a semaphore
which usually doesn't end well.  There are very few cases where we
want the counter works both ways and I personally think we'd be far
better served if those rare cases implement something custom rather
than generic mechanism becoming cryptic trying to cover everything.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
