Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9326B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 11:41:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a72so82644506pge.10
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 08:41:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f69si5572214pfa.164.2017.03.31.08.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 08:41:19 -0700 (PDT)
Date: Fri, 31 Mar 2017 08:41:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2] fs: Remove set but not checked
 AOP_FLAG_UNINTERRUPTIBLE flag.
Message-ID: <20170331154114.GB32460@infradead.org>
References: <1489294781-53494-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489294781-53494-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jeff Layton <jlayton@redhat.com>, Nick Piggin <npiggin@gmail.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
