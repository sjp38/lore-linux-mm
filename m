Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 950976B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 12:49:17 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id h11so19643283wiw.3
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 09:49:17 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v12si62938302wjw.204.2015.02.23.09.49.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 09:49:15 -0800 (PST)
Date: Mon, 23 Feb 2015 18:49:12 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm: shmem: check for mapping owner before dereferencing
Message-ID: <20150223174912.GA25675@lst.de>
References: <1424687880-8916-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424687880-8916-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: hughd@google.com, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, jack@suse.cz, axboe@fb.com

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
