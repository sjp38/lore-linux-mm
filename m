Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8996B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 13:32:37 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so35673171wic.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 10:32:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id da8si48969914wjb.78.2015.10.08.10.32.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 10:32:36 -0700 (PDT)
Date: Thu, 8 Oct 2015 10:32:23 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH -next] mm/vmacache: inline vmacache_valid_mm()
Message-ID: <20151008173223.GB2594@linux-uzut.site>
References: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
 <20151008062115.GA876@swordfish>
 <20151008132331.GC3353@linux-uzut.site>
 <20151008134358.GA601@swordfish>
 <20151008165539.GA2594@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20151008165539.GA2594@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On Thu, 08 Oct 2015, Bueso wrote:
>Thinking a bit more about it, we don't want to be making vmacache_valid_mm()
>visible, as users should only stick to vmacache_valid() calls.
                                         ^^ s/vmacache_valid/vmacache_update

(cache validity is always internal, obviously).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
