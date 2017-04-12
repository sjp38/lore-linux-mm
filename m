Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B50486B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 07:08:44 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v1so6732484qtg.0
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:08:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b189si19213815qkd.90.2017.04.12.04.08.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 04:08:44 -0700 (PDT)
Date: Wed, 12 Apr 2017 13:08:40 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test
 in warn_alloc().
Message-ID: <20170412110840.GA14892@redhat.com>
References: <1491910035-4231-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170412102341.GA13958@redhat.com>
 <201704121941.IAC86936.MFOVOFLFHOStQJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704121941.IAC86936.MFOVOFLFHOStQJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, cl@linux-foundation.org, mgorman@suse.de, penberg@cs.helsinki.fi, mhocko@suse.com

On Wed, Apr 12, 2017 at 07:41:17PM +0900, Tetsuo Handa wrote:
> before proposing this patch, I proposed a patch at
> http://lkml.kernel.org/r/1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> that ignores debug_guardpage_minorder() > 0 only when reporting allocation stalls.
> We can preserve debug_guardpage_minorder() > 0 test if we change to use
> a different function for reporting allocation stalls.
> 
> Which patch do you prefer?

I don't have any preferences regarding this.

Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
