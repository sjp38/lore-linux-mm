Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4706B0260
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:43:46 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b81so15598934lfe.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:43:46 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id yh8si28711775wjb.272.2016.10.19.12.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 12:43:44 -0700 (PDT)
Date: Wed, 19 Oct 2016 20:43:33 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
 potentially sleeping
Message-ID: <20161019194333.GD19173@nuc-i3427.alporthouse.com>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
 <1476773771-11470-3-git-send-email-hch@lst.de>
 <20161019111541.GQ29358@nuc-i3427.alporthouse.com>
 <20161019130552.GB5876@lst.de>
 <CALCETrVqjejgpQVUdem8RK3uxdEgfOZy4cOJqJQjCLtBDnJfyQ@mail.gmail.com>
 <20161019163112.GA31091@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019163112.GA31091@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, joelaf@google.com, jszhang@marvell.com, joaodias@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Oct 19, 2016 at 06:31:12PM +0200, Christoph Hellwig wrote:
> On Wed, Oct 19, 2016 at 08:34:40AM -0700, Andy Lutomirski wrote:
> > 
> > It would be quite awkward for a task stack to get freed from a
> > sleepable context, because the obvious sleepable context is the task
> > itself, and it still needs its stack.  This was true even in the old
> > regime when task stacks were freed from RCU context.
> > 
> > But vfree has a magic automatic deferral mechanism.  Couldn't you make
> > the non-deferred case might_sleep()?
> 
> But it's only magic from interrupt context..
> 
> Chris, does this patch make virtually mapped stack work for you again?

So far, so good. No warns from anyone else.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
