Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 974386B03E5
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 08:09:13 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so15283504wrf.5
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:09:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m29si9543804wrb.254.2017.06.21.05.09.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 05:09:12 -0700 (PDT)
Date: Wed, 21 Jun 2017 14:08:05 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH] percpu_counter: Rename __percpu_counter_add to
 percpu_counter_add_batch
Message-ID: <20170621120805.GG21388@suse.cz>
Reply-To: dsterba@suse.cz
References: <20170620172835.GA21326@htj.duckdns.org>
 <1497981680-6969-1-git-send-email-nborisov@suse.com>
 <20170620194759.GG21326@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170620194759.GG21326@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Nikolay Borisov <nborisov@suse.com>, "David S. Miller" <davem@davemloft.net>, Jens Axboe <axboe@fb.com>, Chris Mason <clm@fb.com>, jbacik@fb.com, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.com>, mgorman@techsingularity.net, linux-kernel@vger.kernel.org

On Tue, Jun 20, 2017 at 03:47:59PM -0400, Tejun Heo wrote:
> From 104b4e5139fe384431ac11c3b8a6cf4a529edf4a Mon Sep 17 00:00:00 2001
> From: Nikolay Borisov <nborisov@suse.com>
> Date: Tue, 20 Jun 2017 21:01:20 +0300
> 
> Currently, percpu_counter_add is a wrapper around __percpu_counter_add
> which is preempt safe due to explicit calls to preempt_disable.  Given
> how __ prefix is used in percpu related interfaces, the naming
> unfortunately creates the false sense that __percpu_counter_add is
> less safe than percpu_counter_add.  In terms of context-safety,
> they're equivalent.  The only difference is that the __ version takes
> a batch parameter.
> 
> Make this a bit more explicit by just renaming __percpu_counter_add to
> percpu_counter_add_batch.
> 
> This patch doesn't cause any functional changes.
> 
> tj: Minor updates to patch description for clarity.  Cosmetic
>     indentation updates.
> 
> Signed-off-by: Nikolay Borisov <nborisov@suse.com>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Chris Mason <clm@fb.com>
> Cc: Josef Bacik <jbacik@fb.com>
> Cc: David Sterba <dsterba@suse.com>

Acked-by: David Sterba <dsterba@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
