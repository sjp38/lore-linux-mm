Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id E44E49003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:28:45 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so168509599ykd.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:28:45 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id t10si16876916ywa.104.2015.07.21.08.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 08:28:44 -0700 (PDT)
Received: by ykax123 with SMTP id x123so168982404yka.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:28:44 -0700 (PDT)
Date: Tue, 21 Jul 2015 11:28:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] perpuc: check pcpu_first_chunk and
 pcpu_reserved_chunk to avoid handling them twice
Message-ID: <20150721152840.GG15934@mtj.duckdns.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-2-git-send-email-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437404130-5188-2-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 20, 2015 at 10:55:29PM +0800, Baoquan He wrote:
> In pcpu_setup_first_chunk() pcpu_reserved_chunk is assigned to point to
> static chunk. While pcpu_first_chunk is got from below code:
> 
> 	pcpu_first_chunk = dchunk ?: schunk;
> 
> Then it could point to static chunk too if dynamic chunk doesn't exist. So
> in this patch adding a check in percpu_init_late() to see if pcpu_first_chunk
> is equal to pcpu_reserved_chunk. Only if they are not equal we add
> pcpu_reserved_chunk to the target array.

So, I don't think this is actually possible.  dyn_size can't be zero
so if reserved chunk is created, dyn chunk is also always created and
thus first chunk can't equal reserved chunk.  It might be useful to
add some comments explaining this or maybe WARN_ON() but I don't think
this path is necessary.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
