Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01D5B2806CB
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 04:20:04 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r71so8701874wrb.17
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 01:20:03 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f25si2440287wrc.189.2017.03.30.01.20.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 01:20:02 -0700 (PDT)
Date: Thu, 30 Mar 2017 10:20:01 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3] mm: Allow calling vfree() from non-schedulable
	context.
Message-ID: <20170330082001.GB11344@lst.de>
References: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490784712-4991-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, Christoph Hellwig <hch@lst.de>, Ingo Molnar <mingo@elte.hu>, Jisheng Zhang <jszhang@marvell.com>, Joel Fernandes <joelaf@google.com>, John Dias <joaodias@google.com>, Matthew Wilcox <willy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

Maybe the right fix is to drop any support for non-user context in
vfree and call vfree_deferred explicitly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
