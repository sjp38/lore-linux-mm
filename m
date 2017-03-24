Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC286B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:17:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 79so10306193pgf.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 09:17:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b8si3402199pgn.113.2017.03.24.09.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 09:17:42 -0700 (PDT)
Date: Fri, 24 Mar 2017 09:17:32 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
Message-ID: <20170324161732.GA23110@bombadil.infradead.org>
References: <1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <59149d48-2a8e-d7c0-8009-1d0b3ea8290b@virtuozzo.com>
 <201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
 <fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu

On Fri, Mar 24, 2017 at 06:05:45PM +0300, Andrey Ryabinin wrote:
> Just fix the drm code. There is zero point in releasing memory under spinlock.

I disagree.  The spinlock has to be held while deleting from the hash
table.  Sure, we could change the API to return the object removed, and
then force the caller to free the object that was removed from the hash
table outside the lock it's holding, but that's a really inelegant API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
