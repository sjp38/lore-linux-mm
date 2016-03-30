Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 417226B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:54:42 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id tt10so32919232pab.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 23:54:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id qe4si4249653pab.195.2016.03.29.23.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 23:54:41 -0700 (PDT)
Message-ID: <1459320877.4102.3.camel@kernel.org>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Vishal Verma <vishal@kernel.org>
Date: Wed, 30 Mar 2016 00:54:37 -0600
In-Reply-To: <20160330063415.GA2132@infradead.org>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	 <20160330063415.GA2132@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Vishal Verma <vishal.l.verma@intel.com>
Cc: Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm@ml01.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-block@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Tue, 2016-03-29 at 23:34 -0700, Christoph Hellwig wrote:
> Hi Vishal,
> 
> still NAK to calling the direct I/O code directly from the dax code.

Hm, I thought this was what you meant -- do the fallback/retry attempts
at the callers of dax_do_io instead of the new dax wrapper function..
Did I misunderstand you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
