Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 543516B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 10:11:59 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id v10so2982344qac.11
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 07:11:59 -0800 (PST)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com. [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id a7si2311347qam.2.2015.01.07.07.11.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 07:11:58 -0800 (PST)
Received: by mail-qa0-f42.google.com with SMTP id n8so3022714qaq.1
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 07:11:58 -0800 (PST)
Date: Wed, 7 Jan 2015 10:11:54 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET v2 block/for-next] writeback: prepare for cgroup
 writeback support
Message-ID: <20150107151154.GB4395@htj.dyndns.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
 <20150107141945.GA29680@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150107141945.GA29680@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz

Hello,

On Wed, Jan 07, 2015 at 06:19:45AM -0800, Christoph Hellwig wrote:
> This needs a rebase over my "backing_dev_info cleanups" series, which
> starts to sort out the bdi lifetime issues.  I think this series is

Shouldn't be a problem.

> fine to go over just that, but before any bigger bdi changes we'll
> also need to sort out the rest of the lifetime issues.  I have some
> WIP patches for that which I'll be able to post soon.

Sure, remaining uses should really pin everything down to the
request_queue.  That said, this patchset shouldn't affect the lifetime
management of bdi's.  Nothing spills out of bdi proper.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
