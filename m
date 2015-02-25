Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 584CD6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:37:43 -0500 (EST)
Received: by pablf10 with SMTP id lf10so8311819pab.6
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:37:43 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id kt1si4520693pdb.20.2015.02.25.13.31.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 13:31:28 -0800 (PST)
Received: by paceu11 with SMTP id eu11so8279083pac.7
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:31:13 -0800 (PST)
Date: Wed, 25 Feb 2015 13:31:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: shmem: check for mapping owner before
 dereferencing
In-Reply-To: <54EB6950.6030909@fb.com>
Message-ID: <alpine.LSU.2.11.1502251328170.9310@eggly.anvils>
References: <1424687880-8916-1-git-send-email-sasha.levin@oracle.com> <20150223174912.GA25675@lst.de> <54EB6950.6030909@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: Christoph Hellwig <hch@lst.de>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, jack@suse.cz

Thanks for the fix, Sasha.

On Mon, 23 Feb 2015, Jens Axboe wrote:
> On 02/23/2015 09:49 AM, Christoph Hellwig wrote:
> > Looks good,
> > 
> > Reviewed-by: Christoph Hellwig <hch@lst.de>

Acked-by: Hugh Dickins <hughd@google.com>

> 
> Shall I funnel this through for-linus?

Please do, thanks.

> 
> -- 
> Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
