Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5F84B6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 07:24:52 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so11457625pad.13
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 04:24:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z9si8201882par.226.2015.01.08.04.24.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 04:24:51 -0800 (PST)
Date: Thu, 8 Jan 2015 04:24:48 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/6] xfs: truncate vs page fault IO exclusion
Message-ID: <20150108122448.GA18034@infradead.org>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420669543-8093-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

> This patchset passes xfstests and various benchmarks and stress
> workloads, so the real question is now:
> 
> 	What have I missed?
> 
> Comments, thoughts, flames?

Why is this done in XFS and not in generic code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
