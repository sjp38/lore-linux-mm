Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFA06B02B4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:55:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u62so46080263pgb.13
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:55:30 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id s62si11065361pfj.490.2017.06.20.12.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 12:55:28 -0700 (PDT)
Date: Tue, 20 Jun 2017 15:55:26 -0400 (EDT)
Message-Id: <20170620.155526.1175661303325942822.davem@davemloft.net>
Subject: Re: [PATCH] percpu_counter: Rename __percpu_counter_add to
 percpu_counter_add_batch
From: David Miller <davem@davemloft.net>
In-Reply-To: <20170620194759.GG21326@htj.duckdns.org>
References: <20170620172835.GA21326@htj.duckdns.org>
	<1497981680-6969-1-git-send-email-nborisov@suse.com>
	<20170620194759.GG21326@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: nborisov@suse.com, jbacik@fb.com, linux-kernel@vger.kernel.org, mgorman@techsingularity.net, clm@fb.com, dsterba@suse.com, darrick.wong@oracle.com, jack@suse.com, axboe@fb.com, linux-mm@kvack.org

From: Tejun Heo <tj@kernel.org>
Date: Tue, 20 Jun 2017 15:47:59 -0400

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

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
